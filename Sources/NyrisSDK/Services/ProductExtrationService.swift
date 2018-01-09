//
//  ProductExtrationService.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 09/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation

final class ProductExtractionService {
        let extractionQueue = DispatchQueue(label: "com.nyris.productExtractionQueue", qos: DispatchQoS.background)
    
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
