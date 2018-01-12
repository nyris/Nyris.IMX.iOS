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
    
    public var outputFormat:String = "application/offers.complete+json"
    
    /// Get products similar to the one visible on the Image
    ///
    /// - Parameters:
    ///   - image: image containing the product
    ///   - position: GPS position
    ///   - isSemanticSearch: to enable/disable semantic search
    ///   - completion: completion
    public func getSimilarProducts(image:UIImage,
                                   position:CLLocation?,
                                   isSemanticSearch:Bool,
                                   completion:@escaping(_ products:[Offer]?, _ error:Error?) -> Void) {
        
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
    private func postSimilarProducts(imageData:Data,
                                     position:CLLocation?,
                                     isSemanticSearch:Bool,
                                     completion:@escaping ( _ products:[Offer]?, _ error:Error?) -> Void) {
        guard
            let request = self.buildRequest(imageData: imageData, position: position,
                                            isSemanticSearch: isSemanticSearch)
            else {
                let message = "Invalid endpoint : creating URL fails"
                let error = RequestError.invalidEndpoint(message: message)
                completion(nil, error)
                return
        }
        
        self.imageMatchingQueue.async {
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
    
    private func buildRequest(imageData:Data, position:CLLocation?, isSemanticSearch:Bool) -> URLRequest? {
        let urlBuilder = URLBuilder().host(self.endpointProvider.imageMatchingServer)
            .appendPath("api/find/")
        
        if let position = position {
            urlBuilder.appendQueryParametres(location: position)
        }
        
        guard let url = urlBuilder.build() else {
            return nil
        }
        let dataLengh = [UInt8](imageData)
        let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "*"
        let AccepteLangageValue = countryCode == "*" ? "" : "\(countryCode),"
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Accept-Language" : "\(AccepteLangageValue) *;q=0.5",
            "Accept" : self.outputFormat,
            "Content-Type" : "image/jpeg",
            "Content-Length" : String(dataLengh.count)
        ]
    
        if isSemanticSearch == true {
            request.addValue("mario", forHTTPHeaderField: "X-Only-Semantic-Search")
        }
        request.httpMethod = RequestMethod.POST.rawValue
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
