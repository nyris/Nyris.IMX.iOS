//
//  BaseAPIRequest.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 22/04/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation
import SystemConfiguration

public typealias OfferCompletion = (_ products:[Offer]?, _ error:Error?) -> Void

/// Handle internet availability
public class BaseService : NSObject {
    
    public let endpointProvider:EndpointsProvider
    internal let client:NyrisClient = NyrisClient.instance
    internal let jsonTask:JSONDownloader
    public var currentTask:URLSessionTask?
    
    public var outputFormat:String = "application/offers.complete+json"
    
    /// By default set to all (*)
    /// Set a value to acceptLanguage to override this behaviour
    /// If you want the device language set this to :
    /// (Locale.current as NSLocale).object(forKey: .languageCode) as? String
    public var acceptLanguage:String = {
        //let languageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "*"
        return "*"
    }()
    
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
    public init(configuration:URLSessionConfiguration? = nil) {
        
        self.endpointProvider  = client.endpointProvider
        
        if let configuration = configuration {
            self.jsonTask = JSONDownloader(apiKey:client.clientID, configuration: configuration, headerMapping: NyrisClient.instance.headerEntriesMapper)
        } else {
            self.jsonTask = JSONDownloader(apiKey:client.clientID,  headerMapping: NyrisClient.instance.headerEntriesMapper)
        }
    }
    
    internal func checkForError() -> Error? {
        guard client.clientID.isEmpty == false else {
            return AuthenticationError.invalidCredential(message: "Invalid credential : make sur clientID is correct and not empty")
            
        }
        return nil
    }
  
    internal func encodeParameters(parameters: [String : String]) -> Data? {
        
        let parameterArray = parameters.map { (key, value) -> String in
            return "\(key)=\(value)"
        }
        
        return parameterArray.joined(separator: "&").data(using: String.Encoding.utf8)
    }
}
