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
    case feedback
    
    public func endpoint(provider:EndpointsProvider, version:String="1") -> URL {
        switch self {
        case .search:
            return URLBuilder(urlString:provider.apiServer)
                .appendPath("find")
                .appendPath("v\(version)")
                .appendPath("text")
                .build()
        case .matching(let latitude, let longitude):
            return URLBuilder(urlString:provider.apiServer)
                .appendPath("find")
                .appendPath("v\(version)")
                .appendQueryParameters(latitude: latitude, longitude: longitude)
                .build()
        case .extraction:
            return URLBuilder(urlString:provider.apiServer)
                .appendPath("find")
                .appendPath("v\(version)")
                .appendPath("regions")
                .build()
        case .feedback:
            return URLBuilder(urlString:provider.apiServer)
                .appendPath("feedback")
                .appendPath("v\(version)")
                .build()
        }
    }
    
    public var method:String {
        switch self {
        case .search:
            return RequestMethod.POST.rawValue
        case .matching:
            return RequestMethod.POST.rawValue
        case .extraction:
            return RequestMethod.POST.rawValue
        case .feedback:
            return RequestMethod.POST.rawValue
        }
    }
}
