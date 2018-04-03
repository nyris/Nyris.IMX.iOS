//
//  ProductExtrationService.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 09/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation
import UIKit

public typealias ExtractedObjectCompletion = (_ objects:[ExtractedObject]?, _ error:Error?) -> Void

public final class ProductExtractionService : BaseService {
    private let extractionQueue:DispatchQueue = DispatchQueue(label: "com.nyris.productExtractionQueue", qos: .background)
    
    /// extract object bounding box from the given image. result is returned in Main thread
    ///
    /// - Parameters:
    ///   - image: scene image
    ///   - completion: ExtractedObjectCompletion
    public func getExtractObjects(from image:UIImage,
                                  completion:@escaping ExtractedObjectCompletion) {
        
        self.extractObjectsOnBackground(from: image) { (extractedObjects, error) in
            DispatchQueue.main.async {
                completion(extractedObjects, error)
            }
        }
    }
    
    /// extract object bounding box from the given image. result is returned in a background thread
    ///
    /// - Parameters:
    ///   - image: scene image
    ///   - completion: ExtractedObjectCompletion
    public func extractObjectsOnBackground(from image: UIImage,
                                           completion: @escaping ExtractedObjectCompletion) {
        
        if let error = self.checkForError() {
            completion(nil, error)
            return
        }

        self.postRequest(image:image, completion:completion)
    }
    
    private func postRequest(image:UIImage, completion:@escaping ExtractedObjectCompletion) {
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
            let error = RequestError.invalidData(message: "invalid image data")
            completion(nil, error)
            return
        }
        
        guard let request = self.buildRequest(imageData: imageData) else {
                let message = "Invalid endpoint : creating URL fails"
                let error = RequestError.invalidEndpoint(message: message)
                completion(nil, error)
                return
        }
        
        self.extractionQueue.async {
            let task = self.jsonTask.execute(request: request, onSuccess: { data in
                let result = self.parseExtractionRespone(data: data, image:image )
                completion(result, nil)
            }, onFailure: { error, _ in
                completion(nil, error)
            })
            
            self.currentTask = task
            task?.resume()
        }
    }
    
    private func buildRequest(imageData:Data) -> URLRequest? {

        let api =  API.extraction
        let url = api.endpoint(provider: endpointProvider)
        
        let dataLengh = [UInt8](imageData)
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Content-Type": "image/jpeg",
            "Content-Length": String(dataLengh.count)
        ]
        
        request.httpMethod = api.method
        request.httpBody = imageData
        return request
    }
    
    private func parseExtractionRespone(data:Data, image:UIImage) -> [ExtractedObject]? {
        
        do {
            let decoder = JSONDecoder()
            let boxes = try decoder.decode([ExtractedObject].self, from: data)
            for var box in boxes {
                box.extractionFromFrame = CGRect(origin: CGPoint.zero, size: image.size)
            }
            return boxes
        } catch {
            return nil
        }
    }
}

// Abstract image resizing/rotating
extension ProductExtractionService {
    
    /// Extract objects bounding boxes from given image, and project these boxes coordinates
    /// from image frame to the given displayFrame
    /// This method completion return on the Main thread
    /// Note: the UIImageView must have a contentMode that preserve the image ratio.
    ///
    /// - Parameters:
    ///   - image: Image to extract from
    ///   - displayFrame: display frame where the boxes should be project to (displayed on).
    ///   - completion: ExtractedObjectCompletion
    public func extractObjects(from image:UIImage,
                               displayFrame: CGRect,
                               completion:@escaping ExtractedObjectCompletion) {
        
        if let error = self.checkForError() {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        // orient/resize image if needed
        let (preparedImage, error) = ImageHelper.prepareImage(image: image, useDeviceOrientation: false)

        guard let validImage = preparedImage else {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }

        self.extractObjectsOnBackground(from: validImage) { (boxes, error) in
            
            guard error == nil, let validBoxes = boxes, validBoxes.isEmpty == false else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            self.projectBoxes(boundingBoxes: validBoxes,
                              imageSource: validImage,
                              displayFrame: displayFrame) { (objects, error) in
                                
                                DispatchQueue.main.async {
                                    completion(objects, error)
                                }
            }
        }
    }
    
    public func projectBoxes(boundingBoxes:[ExtractedObject], imageSource:UIImage, displayFrame: CGRect, completion:@escaping ExtractedObjectCompletion) {
        
        let extractionFrame = CGRect(origin: CGPoint.zero, size: imageSource.size)
        var projectedBoxes:[ExtractedObject] = []
        for box in boundingBoxes {
            
            // project the box from its extraction frame (the image) coordinate, to display frame coordinate
            // The resulting values, are based on origin = (x:0, y:0)
            let projectedObject = box.projectOn(projectionFrame: displayFrame,
                                                from: extractionFrame)
            var projectionRect = projectedObject.region.toCGRect()
            
            // update projected object position to displayFrame positiong
            // by default, the projectedObject will not consider displayFrame positioning
            let newX = displayFrame.origin.x + projectionRect.origin.x
            let newY = displayFrame.origin.y + projectionRect.origin.y
            projectionRect.origin = CGPoint(x: newX, y: newY)
            
            let rectangle = Rectangle.fromCGRect(rect: projectionRect)
            let finalBox = projectedObject.withRegion(region: rectangle)
            projectedBoxes.append(finalBox)
        }
        completion(projectedBoxes, nil)
    }
}
