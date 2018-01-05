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
    
    private var outputFormat:String = "application/everybag.offers+json"
    
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
                                   completion:@escaping(_ products:[OfferInfo]?, _ error:Error?) -> Void) {
        
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
    
    /// Define the output format for the request
    ///
    /// - Parameter format: output format
    public func setOutputFormat(format:String) {
        self.outputFormat = format
    }
    
    /// Send similar porduct post request
    ///
    /// - Parameters:
    ///   - imageData: image of the product
    ///   - position: GPS position
    ///   - isSemanticSearch: semantic search
    ///   - completion: completion
    private func postSimilarProducts(imageData:Data,
                                     position:CLLocation?,
                                     isSemanticSearch:Bool,
                                     completion:@escaping ( _ products:[OfferInfo]?, _ error:Error?) -> Void) {
        guard let request = self.buildRequest(imageData: imageData,
                                              position: position,
                                              isSemanticSearch: isSemanticSearch) else {
            let error = RequestError.invalidEndpoint(message: "Invalid endpoint : creating URL with \(self.endpointProvider.openIDServer) fails")
            completion(nil, error)
            return
        }
        
        self.imageMatchingQueue.async {
            let task = self.jsonTask.execute(with: request) { result in
                switch result {
                case .error(let error):
                    completion(nil, error.error)
                case .success(let json):
                    let offersList = OfferInfo.decodeArray(json: json)
                    completion(offersList,nil)
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
            "user-agent": userAgent,
            "Accept-Language" : "\(AccepteLangageValue) *;q=0.5",
            //Add this if you want to get offers based on our Model
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

// handle the new json model format, this will replace the main class code.
extension ImageMatchingService {
    
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
                                   completion:@escaping(_ products:[Product]?, _ error:Error?) -> Void) {
        
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
                                     completion:@escaping ( _ products:[Product]?, _ error:Error?) -> Void) {
        guard
            let request = self.buildRequest(imageData: imageData, position: position,
                                              isSemanticSearch: isSemanticSearch)
            else {
                let message = "Invalid endpoint : creating URL with \(self.endpointProvider.openIDServer) fails"
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
    
    private func parseMatchingRespone(json:[String : Any]) -> [Product]? {
        let decoder = JSONDecoder()
        
        do {
            
            let data = try JSONEncoder().encode(json)
            let productsResult = try decoder.decode(ProductsResult.self, from: data)
            return productsResult.products
        } catch {
            return nil
        }
    }
}
