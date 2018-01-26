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
    let imageMatchingQueue = DispatchQueue(label: "com.nyris.imageMatchingQueue", qos: DispatchQoS.background)
    
    public var isFirstStageOnly:Bool = false
    public var outputFormat:String = "application/offers.complete+json"
        
    /// By deafult set to the device language.
    /// Set a value to accepteLanguage to override this behaviour
    public var accepteLanguage:String = {
        let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "*"
        return countryCode == "*" ? "" : "\(countryCode)"
    }()
    
    /// Get products similar to the one visible on the Image
    ///
    /// - Parameters:
    ///   - image: image containing the product
    ///   - position: GPS position
    ///   - isSemanticSearch: to enable/disable semantic search
    ///   - completion: completion
    public func getSimilarProducts(image:UIImage,
                                   position:CLLocation? = nil,
                                   isSemanticSearch:Bool,
                                   completion:@escaping OfferCompletion) {
        
        if let error = self.checkForError() {
            completion(nil,error)
            return
        }
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
            let error = RequestError.invalidData(message: "invalid image data")
            completion(nil, error)
            return
        }
        
        self.postSimilarProducts(imageData: imageData,
                                 position: position,
                                 isSemanticSearch: isSemanticSearch,
                                 completion: completion)
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
        completion:@escaping OfferCompletion) {
        
        let request = self.buildRequest(imageData: imageData,
                                        position: position,
                                        isSemanticSearch: isSemanticSearch)
                
        self.imageMatchingQueue.async {
            let task = self.jsonTask.execute(request: request) { (result:Result<[String:AnyObject]>) in
                switch result {
                case .error(let error):
                    completion(nil, error.error)
                case .success(let json):
                    
                    let result = self.parseMatchingRespone(json: json)
                    completion(result,nil)
                }
            }
            
            self.currentTask = task
            task?.resume()
        }
    }
    
    private func buildRequest(imageData:Data, position:CLLocation?, isSemanticSearch:Bool) -> URLRequest {

        let latitude = position?.coordinate.latitude
        let longitude = position?.coordinate.longitude
        let api = API.matching(latitude: latitude, longitude: longitude)
        let dataLengh = [UInt8](imageData)
        
        var request = URLRequest(url: api.endpoint(provider: self.endpointProvider))
        var headers = [
            "Accept-Language" : "\(self.accepteLanguage), *;q=0.5",
            "Accept" : self.outputFormat,
            "Content-Type" : "image/jpeg",
            "Content-Length" : String(dataLengh.count)
        ]
        
        if self.isFirstStageOnly {
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

    private func parseMatchingRespone(json:[String : Any]) -> [Offer]? {
        let decoder = JSONDecoder()
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let productsResult = try decoder.decode(OffersResult.self, from: data)
            return productsResult.products
        } catch {
            print(error)
            return nil
        }
    }
}
