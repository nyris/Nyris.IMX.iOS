//
//  NyrisSDK.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 15/09/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

open class NyrisClient {
    
    public static let instance = NyrisClient()
    private(set) var clientID:String = ""
    private(set) var clientSecret:String = ""
    private(set) var environmentMode:EnvironmentMode!
    
    private init() {
    }
    
    public func setup(clientID:String, clientSecret:String) {
        self.clientID       = clientID
        self.clientSecret   = clientSecret
        self.environmentMode = EnvironmentMode.live
    }
    
    private func setEnvironmentMode(environmentMode:EnvironmentMode) {
        self.environmentMode = environmentMode
    }
    
}
