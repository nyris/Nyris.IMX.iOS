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
    let extractionQueue = DispatchQueue(label: "com.nyris.productExtractionQueue", qos: DispatchQoS.background)
    
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
