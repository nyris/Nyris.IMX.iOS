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
    
    /// extract object bounding box from the given image
    ///
    /// - Parameters:
    ///   - image: scene image
    ///   - completion: ExtractedObjectCompletion
    public func extractObjects(from image:UIImage,
                               completion:@escaping ExtractedObjectCompletion) {
        
        if let error = self.checkForError() {
            completion(nil,error)
            return
        }
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
            let error = RequestError.invalidData(message: "invalid image data")
            completion(nil, error)
            return
        }
        
        self.postSimilarProducts(imageData: imageData, completion: completion)
    }
    
    /// Send similar porduct post request
    ///
    /// - Parameters:
    ///   - imageData: image of the product
    ///   - position: GPS position
    ///   - isSemanticSearch: semantic search
    ///   - completion: ([Product]?, Error?) -> void
    private func postSimilarProducts(imageData:Data,
                                     completion:@escaping ExtractedObjectCompletion) {
        guard let request = self.buildRequest(imageData: imageData) else {
                let message = "Invalid endpoint : creating URL fails"
                let error = RequestError.invalidEndpoint(message: message)
                completion(nil, error)
                return
        }
        
        self.extractionQueue.async {
            let task = self.jsonTask.execute(with: request) { result in
                switch result {
                case .error(let error):
                    completion(nil, error.error)
                case .success(let json):
                    let result = self.parseMatchingRespone(json: json)
                    completion(result,nil)
                }
            }
            
            task?.resume()
        }
    }
    
    private func buildRequest(imageData:Data) -> URLRequest? {
        let urlBuilder = URLBuilder().host(self.endpointProvider.imageMatchingServer)
            .appendPath("api/find/regions")
        
        guard let url = urlBuilder.build() else {
            return nil
        }
        let dataLengh = [UInt8](imageData)
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "user-agent": userAgent,
            "Content-Type" : "image/jpeg",
            "Content-Length" : String(dataLengh.count)
        ]
        
        request.httpMethod = RequestMethod.POST.rawValue
        request.httpBody = imageData
        return request
    }
    
    private func parseMatchingRespone(json:[String : Any]) -> [ExtractedObject]? {
        let decoder = JSONDecoder()
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            //let productsResult = try decoder.decode([ExtractedObject].self, from: data)
            return nil
        } catch {
            print(error)
            return nil
        }
    }
}
