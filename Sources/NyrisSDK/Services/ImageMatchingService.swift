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
            "Accept" : "application/everybag.offers+json",
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
