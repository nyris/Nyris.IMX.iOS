//
//  URLHelper.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 22/04/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation
import CoreLocation

class URLBuilder {
    
    public private(set) var scheme:String = "https"
    private var urlComponents:URLComponents
    
    init() {
        self.urlComponents = URLComponents()
        self.urlComponents.scheme = self.scheme
    }
    
    /// url scheme (http/https)
    @discardableResult
    func scheme(_ scheme:String) -> URLBuilder {
        return self
    }
    
    // add the path to the desired endpoint
    @discardableResult
    func appendPath(_ path:String) -> URLBuilder {
        guard path.isEmpty == false else {
            return self
        }
        var path = path
        // to get URL, path must start with /
        if path.hasPrefix("/") == false {
            path = "/\(path)"
        }
        self.urlComponents.path.append(path)
        //self.urlComponents.path = path
        return self
    }
    
    /// add query (key,value) to the url path, if the query exist it's value will be updated
    @discardableResult
    func appendQueryParametre( key:String, value:String) -> URLBuilder {
        guard key.isEmpty == false , value.isEmpty == false else {
            return self
        }
        let query = URLQueryItem(name: key, value: value)
        
        if let queriyItems = self.urlComponents.queryItems, queriyItems.isEmpty == false {
            
            if var exitingQuery = queriyItems.first(where: { (storedQuery) -> Bool in
                storedQuery.name == query.name
            }) {
                exitingQuery.value = value
            } else {
                self.urlComponents.queryItems?.append(query)
            }
            
        } else {
            self.urlComponents.queryItems?.append(query)
        }
        return self
    }
    
    @discardableResult
    func appendQueriesParametres(queries:[String:String]) -> URLBuilder {
        for (key,value) in queries {
            guard key.isEmpty == false, value.isEmpty == false else {
                continue
            }
            self.appendQueryParametre(key: key, value: value)
        }
        return self
    }
    
    @discardableResult
    func appendQueryParametres(location:CLLocation?) -> URLBuilder {
        guard let location = location else {
            return self
        }
        
        self.appendQueryParametre(key: "lat", value: String(location.coordinate.latitude))
            .appendQueryParametre(key: "lon", value: String(location.coordinate.longitude))
            .appendQueryParametre(key: "acc", value: String(location.horizontalAccuracy))
        return self
    }
    
    // change the port for the endpoint
    @discardableResult
    func port(_ port:Int) -> URLBuilder {
        self.urlComponents.port = port
        return self
    }
    
    func host(_ host:String) -> URLBuilder {
        guard host.isEmpty == false else {
            return self
        }
        self.urlComponents.host = host
        return self
    }
    
    /// genreate a url based on scheme/queries/encode
    func build() -> URL? {
        return self.urlComponents.url
    }
}
