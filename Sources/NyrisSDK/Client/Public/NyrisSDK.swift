//
//  NyrisSDK.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 15/09/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

open class NyrisClient {
    
    public static let instance:NyrisClient = NyrisClient()
    public private(set) var clientID:String = ""
    public private(set) var endpointProvider:EndpointsProvider!
    
    private init() {
    }
    
    public func setup(clientID:String, endpointProvider: EndpointsProvider = NyrisDefaultEndpoints.live) {
        self.clientID       = clientID
        self.endpointProvider = endpointProvider
    }
}
