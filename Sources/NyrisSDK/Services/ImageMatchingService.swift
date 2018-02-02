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

final public class ImageMatchingService : BaseService {
    let imageMatchingQueue:DispatchQueue = DispatchQueue(label: "com.nyris.imageMatchingQueue", qos: .background)
    
    public var isFirstStageOnly:Bool = false
    
    /// Define the matching service result json format
    public var outputFormat:String = "application/offers.complete+json"
        
    /// By deafult set to the device language.
    /// Set a value to accepteLanguage to override this behaviour
    public var accepteLanguage:String = {
        let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "*"
        return countryCode
    }()
    
    /// Get products similar to the one visible on the Image
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
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
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
    
    /// Send similar porduct post request
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
                let result = self.parseMatchingRespone(data: data)
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
        let dataLengh = [UInt8](imageData)
        
        var request = URLRequest(url: api.endpoint(provider: self.endpointProvider))
        var headers = [
            "Accept-Language" : "\(self.accepteLanguage);q=0.5",
            "Accept" : self.outputFormat,
            "Content-Type" : "image/jpeg",
            "Content-Length" : String(dataLengh.count)
        ]
        
        if isFirstStageOnly {
            headers["X-Only-First-Stage"] = "nyris"
        }
        
        if isSemanticSearch == true {
            headers["X-Only-Semantic-Search"] = "nyris"
        }
        
        request.allHTTPHeaderFields = headers
        request.httpMethod = api.method
        request.httpBody = imageData
        return request
    }
}

// Parsing
extension ImageMatchingService {

    private func parseMatchingRespone(data:Data) -> [Offer]? {
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
    
    /// Search for offers that matches the given image.
    /// This method will automaticly resize the given image to 512xHeight/Widthx512
    /// This method return on the main thread
    /// - Parameters:
    ///   - image: product image
    ///   - position: user position
    ///   - isOnlySimilarOffers: Enable/Disable semantic search
    ///   - isFirstStageOnly: isFirstStageOnly
    ///   - useDeviceOrientation : rotate the image based on device orientation.
    ///     usefull if the image was taken from the device camera.
    ///     If your image is already in the correct rotation, ignore this parametre.
    ///   - completion: (products:[Offer]?, error:Error) -> Void
    public func match(image:UIImage,
                      position:CLLocation? = nil,
                      isOnlySimilarOffers:Bool = false,
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
                                isSemanticSearch: isOnlySimilarOffers,
                                isFirstStageOnly:isFirstStageOnly,
                                completion: completion)
    }
}
