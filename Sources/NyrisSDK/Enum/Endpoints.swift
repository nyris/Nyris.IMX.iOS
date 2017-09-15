//
//  Endpoints.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 18/04/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

private protocol EndpointsProvider {
    
    var openIDServer: String { get }
    var imageMatchingServer: String { get }
    var apiServer: String { get }
    
}

private struct LiveEndpoints : EndpointsProvider {
    
    public var apiServer: String = "api.wundercart.de"
    public var imageMatchingServer: String = "imagematching.wundercart.de"
    public var openIDServer: String = "openid.wundercart.de"
    
}

private struct DevelopementEndpoints : EndpointsProvider {
    
    public var apiServer: String = "api.wundercart.de"
    public var imageMatchingServer: String = "imagematching.wundercart.de"
    public var openIDServer: String = "openid.dev.everybag.de"
    
}

private struct StagingEndpoints : EndpointsProvider {
    
    public var apiServer: String = "api.wundercart.de"
    public var imageMatchingServer: String = "imagematching.wundercart.de"
    public var openIDServer: String = "openid.dev.everybag.de"
    
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
        
        switch self.environmentMode {
        case .live:
            self.endpointsProvider = LiveEndpoints()
        case .developement :
            self.endpointsProvider = DevelopementEndpoints()
        case .staging:
            self.endpointsProvider = StagingEndpoints()
        }
    }
}
