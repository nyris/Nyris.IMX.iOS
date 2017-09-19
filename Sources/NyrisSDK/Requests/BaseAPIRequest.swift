//
//  BaseAPIRequest.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 22/04/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation
import SystemConfiguration

/// Handle token and internet availability
public class BaseService : NSObject {
    
    public let endpointProvider:Endpoints
    public let environmentMode:EnvironmentMode
    let client:NyrisClient = NyrisClient.instance
    let jsonTask:JSONDownloader
    
    var token:AuthenticationToken? {
        return client.token
    }
    
    public var isValidToken:Bool {
        guard let token = self.token, token.token.isEmpty == false else {
            return false
        }
        return token.isExpired == false
    }
    
    public var userAgent : String {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0"
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "0"
        
        let bundle = Bundle.main.bundleIdentifier ?? ""
        let osVersion = ProcessInfo().operatingSystemVersion
        let osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        let userAgent = "nyris/\(bundle)-\(appVersion)-build(\(appBuild)) (iOS; \(osVersionString))"
        
        return userAgent
    }
    
    /// instantiate a BaseAPIRequest in live mode
    ///
    /// - Parameter configuration: session configuration
    public init(configuration:URLSessionConfiguration? = nil, environmentMode:EnvironmentMode = .live) {
        
        self.environmentMode   = environmentMode
        self.endpointProvider  = Endpoints(environmentMode: self.environmentMode)
        
        if let configuration = configuration {
            self.jsonTask = JSONDownloader(configuration: configuration)
        } else {
            self.jsonTask = JSONDownloader()
        }
    }
    
    func checkForError() -> Error? {
        guard client.clientID.isEmpty == false || client.clientSecret.isEmpty == false else {
            
            return AuthenticationError.invalidCredential(message: "Invalid credential : make sur clientID or clientSecret are correct and not empty")
            
        }
        return nil
    }
  
    func encodeParameters(parameters: [String : String]) -> Data? {
        
        let parameterArray = parameters.map { (key, value) -> String in
            return "\(key)=\(value)"
        }
        
        return parameterArray.joined(separator: "&").data(using: String.Encoding.utf8)
    }
}
