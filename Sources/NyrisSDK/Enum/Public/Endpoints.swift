//
//  Endpoints.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 18/04/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

/// Provide API endpoint for different services supported by the SDK. It can also be used to create different environment like dev, prod and staging.
public protocol EndpointsProvider {
    /// openIDServer endpoint
    var openIDServer: String { get }
    /// imageMatchingServer endpoint
    var imageMatchingServer: String { get }
    /// apiServer endpoint
    var apiServer: String { get }
}

/// Provide service url 
public struct NyrisDefaultEndpoints : EndpointsProvider {
    public static var live : EndpointsProvider {
        return NyrisDefaultEndpoints()
    }
    public static var development : EndpointsProvider {
        return NyrisDefaultEndpoints()
    }
    public static var staging : EndpointsProvider {
        return NyrisDefaultEndpoints()
    }
    
    public var apiServer: String = "https://api.nyris.io"
    public var imageMatchingServer: String = "https://api.nyris.io"
    public var openIDServer: String = "https://api.nyris.io"
}
