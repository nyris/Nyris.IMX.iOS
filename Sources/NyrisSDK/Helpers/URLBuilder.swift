//
//  URLHelper.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 22/04/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation
import CoreLocation

internal class URLBuilder {
    
    public private(set) var scheme:String = "https"
    private var urlComponents:URLComponents
    
    internal init() {
        self.urlComponents = URLComponents()
        self.urlComponents.scheme = self.scheme
    }
    
    internal convenience init(host:String) {
        self.init()
        self.host(host)
    }
    
    /// url scheme (http/https)
    @discardableResult
    internal func scheme(_ scheme:String) -> URLBuilder {
        return self
    }
    
    // add the path to the desired endpoint
    @discardableResult
    internal func appendPath(_ path:String) -> URLBuilder {
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
    internal func appendQueryParametre( key:String, value:String) -> URLBuilder {
        guard key.isEmpty == false, value.isEmpty == false else {
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
    internal func appendQueriesParametres(queries:[String:String]) -> URLBuilder {
        for (key, value) in queries {
            guard key.isEmpty == false, value.isEmpty == false else {
                continue
            }
            self.appendQueryParametre(key: key, value: value)
        }
        return self
    }
    
    @discardableResult
    internal func appendQueryParametres(latitude:Double?, longitude:Double?) -> URLBuilder {
        guard let longitude = longitude, let latitude = latitude else {
            return self
        }
        let location = CLLocation(latitude: CLLocationDegrees(longitude),
                                  longitude: CLLocationDegrees(latitude))
        return self.appendQueryParametres(location:location)
    }
    
    @discardableResult
    internal func appendQueryParametres(location:CLLocation?) -> URLBuilder {
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
    internal func port(_ port:Int) -> URLBuilder {
        self.urlComponents.port = port
        return self
    }
    
    @discardableResult
    internal func host(_ host:String) -> URLBuilder {
        guard host.isEmpty == false else {
            return self
        }
        self.urlComponents.host = host
        return self
    }
    
    /// genreate a url based on scheme/queries/encode
    internal func build() -> URL {
        guard let url = self.urlComponents.url else {
            fatalError("Trying to build an invalid url")
        }
        return url
    }
}
