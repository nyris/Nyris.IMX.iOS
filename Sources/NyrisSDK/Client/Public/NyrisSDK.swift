//
//  NyrisSDK.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 15/09/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

/// Nyris SDK Client setup interface. This should be used to set the API key, endpoints and mapping.
open class NyrisClient {
    
    /// nyris SDK client setup interface  singleton
    public static let instance:NyrisClient = NyrisClient()
    /// clientID
    public private(set) var clientID:String = ""
    /// endpointProvider, defaults to nyris live endpoints
    public private(set) var endpointProvider:EndpointsProvider!
    /// header mapping to be used in case of proxies, defaults to nyris mapping
    public private(set) var headerEntriesMapper: HeaderMapper!
    private init() {
    }
    
    /// Setup the Nyris SDK client.
    /// - Parameters:
    ///   - clientID: clientID
    ///   - endpointProvider: endpointProvider, defaults to nyris live endpoints
    ///   - headerEntriesMapper: header mapping to be used in case of proxies, defaults to nyris mapping
    public func setup(clientID:String,
                      endpointProvider: EndpointsProvider = NyrisDefaultEndpoints.live,
                      headerEntriesMapper: HeaderMapper = NyrisHeaderMapping.default) {
        self.clientID       = clientID
        self.endpointProvider = endpointProvider
        self.headerEntriesMapper = headerEntriesMapper
    }
}
