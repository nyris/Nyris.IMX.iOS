//
//  NyrisAPI.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 25/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation

internal enum API {
    case search
    case matching(latitude:Double?, longitude:Double?)
    case extraction
    
    func endpoint(provider:EndpointsProvider, version:String="1") -> URL {
        switch self {
        case .search:
            return URLBuilder(host:provider.apiServer)
                .appendPath("find")
                .appendPath("v\(version)")
                .appendPath("text")
                .build()
        case .matching(let latitude, let longitude):
            return URLBuilder(host:provider.apiServer)
                .appendPath("find")
                .appendPath("v\(version)")
                .appendQueryParametres(latitude: latitude, longitude: longitude)
                .build()
        case .extraction:
            return URLBuilder(host:provider.apiServer)
                .appendPath("find")
                .appendPath("v\(version)")
                .appendPath("regions")
                .build()
        }
    }
    
    var method:String {
        switch self {
        case .search:
            return RequestMethod.POST.rawValue
        case .matching:
            return RequestMethod.POST.rawValue
        case .extraction:
            return RequestMethod.POST.rawValue
        }
    }
}
