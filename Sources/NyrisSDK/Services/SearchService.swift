//
//  SearchService.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 20/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation

public final class SearchService : BaseService {
    
    let searchQueue:DispatchQueue = DispatchQueue(label: "com.nyris.search", qos: .background)
    
    public var outputFormat:String = "application/offers.complete+json"
    
    /// By deafult set to the device language.
    /// Set a value to accepteLanguage to override this behaviour
    public var accepteLanguage:String = {
        let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "*"
        return countryCode == "*" ? "" : "\(countryCode)"
    }()
    
    private var url:URL {
        return API.search.endpoint(provider: self.endpointProvider)
    }
    
    public func search(query:String, completion:@escaping OfferCompletion) {
        if let error = self.checkForError() {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        guard query.isEmpty == false, query.count > 1 else {
            let error = RequestError.invalidData(message: "Empty or small(<2) query text")
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        self.postSimilarProducts(query: query) { (offers, error) in
            DispatchQueue.main.async {
                completion(offers, error)
            }
        }
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
                    completion(result, nil)
                }
            })
            
            self.currentTask = task
            task?.resume()
        }
    }
    
    private func buildRequest(query:String) -> URLRequest? {

        guard let data = query.data(using: .utf8) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Accept-Language" : "\(self.accepteLanguage), *;q=0.5",
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
