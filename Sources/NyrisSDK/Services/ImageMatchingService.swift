//
//  ImageMatchingService.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 24/06/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

final public class ImageMatchingService : BaseService, XOptionsProtocol {
    
    private let imageMatchingQueue:DispatchQueue = DispatchQueue(label: "com.nyris.imageMatchingQueue", qos: .background)
    
    public var xOptions: String = ""
    
    /// Get products similar to the image's objects.
    /// This method will not apply any transformation on the given image.
    /// The caller is responsible for resizing/rotating the image
    
    /// completion will return on the main thread
    /// - Parameters:
    ///   - image: image containing the product
    ///   - position: GPS position
    ///   - isSemanticSearch: to enable/disable semantic search
    ///   - completion: completion
    public func getSimilarProducts(image:UIImage,
                                   position:CLLocation? = nil,
                                   isSemanticSearch:Bool,
                                   isFirstStageOnly:Bool = false,
                                   completion:@escaping OfferCompletion) {
        
        if let error = self.checkForError() {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            let error = RequestError.invalidData(message: "invalid image data")
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        self.postSimilarProducts(
            imageData: imageData,
            position: position,
            isSemanticSearch: isSemanticSearch,
            isFirstStageOnly: isFirstStageOnly) { (offers, error) in
                DispatchQueue.main.async {
                    completion(offers, error)
                }
        }
    }
    
    /// Send similar product post request
    ///
    /// - Parameters:
    ///   - imageData: image of the product
    ///   - position: GPS position
    ///   - isSemanticSearch: semantic search
    ///   - completion: ([Product]?, Error?) -> void
    private func postSimilarProducts(
        imageData:Data,
        position:CLLocation?,
        isSemanticSearch:Bool,
        isFirstStageOnly:Bool,
        completion:@escaping OfferCompletion) {
        
        let request = self.buildRequest(imageData: imageData,
                                        position: position,
                                        isSemanticSearch: isSemanticSearch,
                                        isFirstStageOnly:isFirstStageOnly)
                
        self.imageMatchingQueue.async {
            let task = self.jsonTask.execute(request: request, onSuccess: { data in
                let result = self.parseMatchingResponse(data: data)
                completion(result, nil)
            }, onFailure: { (error, _) in
                completion(nil, error)
            })
            
            self.currentTask = task
            task?.resume()
        }
    }
    
    private func buildRequest(imageData:Data, position:CLLocation?, isSemanticSearch:Bool,
                              isFirstStageOnly:Bool) -> URLRequest {

        let latitude = position?.coordinate.latitude
        let longitude = position?.coordinate.longitude
        let api = API.matching(latitude: latitude, longitude: longitude)
        let dataLength = [UInt8](imageData)
        
        var request = URLRequest(url: api.endpoint(provider: self.endpointProvider))
        var headers = [
            "Accept-Language" : "\(self.acceptLanguage);q=0.5",
            "Accept" : self.outputFormat,
            "Content-Type" : "image/jpeg",
            "Content-Length" : String(dataLength.count)
        ]
        
        if isFirstStageOnly {
            headers["X-Only-First-Stage"] = "nyris"
        }
        
        if isSemanticSearch == true {
            headers["X-Only-Semantic-Search"] = "nyris"
        }
        
        if self.xOptions.isEmpty == false {
            headers["X-Options"] = self.xOptions
        }
        
        request.allHTTPHeaderFields = headers
        request.httpMethod = api.method
        request.httpBody = imageData
        return request
    }
}

// Parsing
extension ImageMatchingService {

    private func parseMatchingResponse(data:Data) -> [Offer]? {
        do {
            let decoder = JSONDecoder()
            let productsResult = try decoder.decode(OffersResult.self, from: data)
            return productsResult.products
        } catch {
            print(error)
            return nil
        }
    }
}

// scaling abstraction extension
extension ImageMatchingService {
    
    /// Search for offers that matches the given image's objects.
    /// This method will automatically resize the given image to 512xHeight/Widthx512
    /// If the given image size is less than 512 on both weight and height, it will fails
    /// This method return on the main thread
    /// - Parameters:
    ///   - image: product image
    ///   - position: user position
    ///   - isSemanticSearch: enable MESS search only
    ///   - isFirstStageOnly: enable exact match
    ///   - useDeviceOrientation : rotate the image based on device orientation.
    ///     useful if the image was taken from the device camera.
    ///     If your image is already in the correct rotation, ignore this parameter.
    ///   - completion: (products:[Offer]?, error:Error) -> Void
    public func match(image:UIImage,
                      position:CLLocation? = nil,
                      isSemanticSearch:Bool = false,
                      isFirstStageOnly:Bool = false,
                      useDeviceOrientation:Bool = false,
                      completion:@escaping OfferCompletion ) {
        
        if let error = self.checkForError() {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }

        // orient/resize image if needed
        let (preparedImage, error) = ImageHelper.prepareImage(image: image,
                                                              useDeviceOrientation: useDeviceOrientation)
        if let error = error, preparedImage == nil {
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
        
        self.getSimilarProducts(image: validImage,
                                isSemanticSearch: isSemanticSearch,
                                isFirstStageOnly:isFirstStageOnly,
                                completion: completion)
    }
}
