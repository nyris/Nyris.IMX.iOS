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
    public init(configuration:URLSessionConfiguration? = nil) {
        
        self.environmentMode    = .live
        self.endpointProvider  = Endpoints(environmentMode: self.environmentMode)
        
        if let configuration = configuration {
            self.jsonTask = JSONDownloader(configuration: configuration)
        } else {
            self.jsonTask = JSONDownloader()
        }
    }
    
    private init(environmentMode:EnvironmentMode, configuration:URLSessionConfiguration? = nil) {
        self.environmentMode    = environmentMode
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

    /// Request token refresh
    ///
    /// - Parameter completion: completion closure
    func refreshToken(completion:@escaping AuthenticationCompletion) {
        if let error = self.checkForError() {
            completion(nil,error)
            return
        }

        guard let request = self.buildRefreshTokenRequest() else {
            let error = RequestError.invalidEndpoint(message: "Invalid Request : creating URL with \(self.endpointProvider.openIDServer) fails")
            completion(nil, error)
            return // error
        }
        
        let task = self.jsonTask.execute(with: request) { result in
            switch result {
            case .error(let error):
                completion(nil,error.error)
                break
            case .success(let json):
                let token = AuthenticationToken.parse(json: json)
                token?.saveToLocalStore()
                self.client.token = token
                completion(token,nil)
                break
            }
        }
        task?.resume()
    }

    private func buildRefreshTokenRequest() -> URLRequest? {
        let clientSecret = client.clientSecret
        let clientID = client.clientID
        let parameters:[String:String] = ["client_id": clientID,
                                          "client_secret": clientSecret,
                                          GrantType.key: GrantType.refreshToken.rawValue,
                                          AuthScope.key: AuthScope.hunterGatherer.rawValue]
        
        let urlBuilder = URLBuilder().host(self.endpointProvider.openIDServer)
            .appendPath("connect/token")
        guard let url = urlBuilder.build() else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.POST.rawValue
        
        if let body = self.encodeParameters(parameters: parameters) {
            request.httpBody = body
        }
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func encodeParameters(parameters: [String : String]) -> Data? {
        
        let parameterArray = parameters.map { (key, value) -> String in
            return "\(key)=\(value)"
        }
        
        return parameterArray.joined(separator: "&").data(using: String.Encoding.utf8)
    }
}
