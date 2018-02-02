//
//  ProductExtrationService.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 09/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation

public typealias ExtractedObjectCompletion = (_ objects:[ExtractedObject]?, _ error:Error?) -> Void

public final class ProductExtractionService : BaseService {
    let extractionQueue:DispatchQueue = DispatchQueue(label: "com.nyris.productExtractionQueue", qos: .background)
    
    /// extract object bounding box from the given image. result is returned in Main thread
    ///
    /// - Parameters:
    ///   - image: scene image
    ///   - completion: ExtractedObjectCompletion
    public func extractObjects(from image:UIImage,
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
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
            let error = RequestError.invalidData(message: "invalid image data")
            completion(nil, error)
            return
        }
        self.postRequest(imageData: imageData, completion: completion)
    }
    
    private func postRequest(imageData:Data, completion:@escaping ExtractedObjectCompletion) {
        guard let request = self.buildRequest(imageData: imageData) else {
                let message = "Invalid endpoint : creating URL fails"
                let error = RequestError.invalidEndpoint(message: message)
                completion(nil, error)
                return
        }
        
        self.extractionQueue.async {
            let task = self.jsonTask.execute(request: request, onSuccess: { data in
                let result = self.parseExtractionRespone(data: data)
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
    
    private func parseExtractionRespone(data:Data) -> [ExtractedObject]? {
        
        do {
            let decoder = JSONDecoder()
            let boxes = try decoder.decode([ExtractedObject].self, from: data)
            return boxes
        } catch {
            print(error)
            return nil
        }
    }
}

// Abstract image resizing/rotating
extension ProductExtractionService {
    
    /// Extract objects bounding boxes from given image, and project these boxes coordinates to the displayFrame
    /// Note: the UIImageView must have a contentMode equal to .scaleAspectFit
    ///
    /// - Parameters:
    ///   - image: Image to extract from
    ///   - displayFrame: display frame where the boxes should project to.
    ///   - completion: ExtractedObjectCompletion
    public func extract(from image:UIImage,
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
        if let error = error {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        guard let validImage = preparedImage else {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }

        self.extractObjectsOnBackground(from: validImage) { (boxes, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let validBoxes = boxes, validBoxes.isEmpty == false else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let extractionFrame = CGRect(origin: CGPoint.zero, size: image.size)

            self.projectBoxes(boundingBoxes: validBoxes,
                              extractionFrame: extractionFrame,
                              displayFrame: displayFrame) { (objects, error) in
                                
                                DispatchQueue.main.async {
                                    completion(objects, error)
                                }
            }
        }
    }
    
    func projectBoxes(boundingBoxes:[ExtractedObject], extractionFrame:CGRect, displayFrame: CGRect, completion:@escaping ExtractedObjectCompletion) {
        
        var projectedBoxes:[ExtractedObject] = []
        for box in boundingBoxes {
            let projected = box.projectOn(projectionFrame: displayFrame, from: extractionFrame)
            var project = projected.region.toCGRect()
            
            // apply display frame offset
            // this will offset the image to the correct UIImageView display zone
            // without this, the box will have offset dependant of the image displayed
            // The displayed image coordinate is the parent coordinate of the box
            // Applying the offset will allow the box to correctly be drawn on display frame coordinate
            let newX = displayFrame.origin.x + project.origin.x
            let newY = displayFrame.origin.y + project.origin.y
            project.origin = CGPoint(x: newX, y: newY)
            
            let rectangle = Rectangle.fromCGRect(rect: project)
            let finalBox = projected.withRegion(region: rectangle)
            projectedBoxes.append(finalBox)
        }
        completion(projectedBoxes, nil)
    }
}
