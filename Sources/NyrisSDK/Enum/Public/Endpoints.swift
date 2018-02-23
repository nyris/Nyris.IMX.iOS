//
//  Endpoints.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 18/04/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

internal protocol EndpointsProvider {
    var openIDServer: String { get }
    var imageMatchingServer: String { get }
    var apiServer: String { get }
}

private struct LiveEndpoints : EndpointsProvider {
    
    public var apiServer: String = "api.nyris.io"
    public var imageMatchingServer: String = "api.nyris.io"
    public var openIDServer: String = "api.nyris.io"
    
}

/// Provide service url based on EnvirenementMode
public struct Endpoints : EndpointsProvider {
    
    private(set) var environmentMode:EnvironmentMode
    private var endpointsProvider:EndpointsProvider
    
    public var apiServer: String {
        return self.endpointsProvider.apiServer
    }
    
    public var imageMatchingServer: String {
        return self.endpointsProvider.imageMatchingServer
    }
    
    public var openIDServer: String {
        return self.endpointsProvider.openIDServer
    }
    
    init(environmentMode:EnvironmentMode) {
        self.environmentMode = environmentMode
        self.endpointsProvider = LiveEndpoints()
    }
}
