//
//  SearchService.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 20/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation

public final class SearchService : BaseService {
    
    let searchQueue = DispatchQueue(label: "com.nyris.search", qos: DispatchQoS.background)
    
    public var outputFormat:String = "application/offers.complete+json"
    
    private var url:URL? {
        return URLBuilder().host(self.endpointProvider.imageMatchingServer)
            .appendPath("api")
            .appendPath("find")
            .appendPath("text")
            .build()
    }
    
    public func search(query:String, completion:@escaping OfferCompletion) {
        if let error = self.checkForError() {
            completion(nil,error)
            return
        }
        
        guard query.isEmpty == false, query.count > 1 else {
            let error = RequestError.invalidData(message: "Empty or small(<2) query text")
            completion(nil, error)
            return
        }
        
        self.postSimilarProducts(query: query, completion: completion)
    }

    private func postSimilarProducts(query:String,
                                     completion:@escaping OfferCompletion) {
        guard let request = self.buildRequest(query: query) else {
            let message = "Invalid endpoint : creating URL fails"
            let error = RequestError.invalidEndpoint(message: message)
            completion(nil, error)
            return
        }
        
        self.searchQueue.async {
            let task = self.jsonTask.execute(request: request, completion: { (result:Result<Data>) in
                switch result {
                case .error(let error):
                    completion(nil, error.error)
                case .success(let data):
                    let result = self.parseMatchingRespone(data: data)
                    completion(result,nil)
                }
            })
            
            task?.resume()
        }
    }
    
    private func buildRequest(query:String) -> URLRequest? {

        guard let url = self.url, let data = query.data(using: .utf8)else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "*"
        let AccepteLangageValue = countryCode == "*" ? "" : "\(countryCode),"
        
        request.allHTTPHeaderFields = [
            "Accept-Language" : "\(AccepteLangageValue) *;q=0.5",
            "Accept" : self.outputFormat,
            "Content-Length" : String(data.count),
            "Content-Type" : "text/plain"
        ]
        
        request.httpMethod = RequestMethod.POST.rawValue
        request.httpBody = data
        return request
    }
    
    private func parseMatchingRespone(data:Data) -> [Offer]? {
        let decoder = JSONDecoder()
        
        do {
            let productsResult = try decoder.decode(OffersResult.self, from: data)
            return productsResult.products
        } catch {
            print(error)
            return nil
        }
    }
}
