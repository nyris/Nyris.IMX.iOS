//
//  Endpoints.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 18/04/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

public protocol EndpointsProvider {
    var openIDServer: String { get }
    var imageMatchingServer: String { get }
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
