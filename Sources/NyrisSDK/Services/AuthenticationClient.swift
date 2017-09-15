//
//  AuthenticationManager.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 18/04/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

public typealias AuthenticationCompletion = (_ token:AuthenticationToken?, _ error:Error?) -> Void

final public class AuthenticationClient : BaseService {
    
    /// Request authentication token, using  clientID/clientSecret credentials
    ///
    /// - Parameters:
    ///   - completion: completion closure
    public func authenticate(for scope:AuthScope, completion:@escaping AuthenticationCompletion) {
        
        guard NyrisClient.instance.clientID.isEmpty == false else {
            fatalError("You are trying to call authentication without setting clientID, " +
                "please call : NyrisClient.instance.setup(clientID:String,clientSecret:String")
        }
        guard NyrisClient.instance.clientSecret.isEmpty == false else {
            fatalError("You are trying to call authentication without setting clientSecret, " +
                "please call : NyrisClient.instance.setup(clientID:String,clientSecret:String")
        }
    
        let clientID = NyrisClient.instance.clientID
        let clientSecret = NyrisClient.instance.clientSecret
        
        var parameters:[String:String] = ["client_id": clientID,
                                          "client_secret": clientSecret,
                                          GrantType.key: GrantType.clientCredentials.rawValue,
                                          AuthScope.key: scope.rawValue]
        
        if let validToken = client.token, validToken.isExpired == true {
            // refresh the token with proper api
            // TODO: unsuported right now, refresh scope should be used instead of password scope
            //parameters[GrantType.key] = GrantType.refreshToken.rawValue
            parameters[GrantType.key] = GrantType.clientCredentials.rawValue
        }
    
        self.postAuthentication(parameters: parameters) { (token, error) in
            completion(token,error)
        }

    }
    
    /// Request authentication token, with username/password credentials
    ///
    /// - Parameters:
    ///   - username: user name
    ///   - password: password
    ///   - completion: completion closure
    public func authentification(username:String, password:String, for scope:AuthScope, completion:@escaping AuthenticationCompletion) {
        
        guard NyrisClient.instance.clientID.isEmpty == false else {
            fatalError("You are trying to call authentication without setting clientID, " +
                "please call : NyrisClient.instance.setup(clientID:String,clientSecret:String")
        }
        
        guard username.isEmpty == false, password.isEmpty == false else {
            let error = AuthenticationError.invalidCredential(message: "username or password is empty")
            completion(nil, error)
            return
        }
        
        let clientID = NyrisClient.instance.clientID
        var parameters:[String:String] = ["username": username,
                                          "password": password,
                                          "client_id": clientID,
                                          GrantType.key: GrantType.password.rawValue,
                                          AuthScope.key: scope.rawValue]
        
        if let token = token, token.isExpired == true {
            // refresh the token with proper api
            // TODO: unsuported right now, refresh scope should be used instead of password scope
            //parameters[GrantType.key] = GrantType.refreshToken.rawValue
            parameters[GrantType.key] = GrantType.password.rawValue
        }
        
        self.postAuthentication(parameters: parameters) { (token, error) in
            completion(token,error)
        }
    }
    
    /// execute post authentication
    ///
    /// - Parameters:
    ///   - parameters: request headers parametres
    ///   - completion: request completion closure
    private func postAuthentication(parameters:[String:String], completion:@escaping AuthenticationCompletion) {
        
        if let error = self.checkForError() {
            completion(nil,error)
            return
        }
        
        guard let request = self.buildAuthenticationRequest(parameters: parameters) else {
            let error = RequestError.invalidEndpoint(message: "Invalid endpoint : creating URL with \(self.endpointProvider.openIDServer) failed")
            completion(nil, error)
            return
        }
        let task = jsonTask.execute(with: request) { result in
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
}

extension AuthenticationClient {
    
    /// Generating authentication request object
    ///
    /// - Parameter parameters: Header parametres
    /// - Returns: URLRequest
    fileprivate func buildAuthenticationRequest(parameters:[String:String]) -> URLRequest? {
        let urlBuilder = URLBuilder().host(self.endpointProvider.openIDServer).appendPath("connect/token")
        
        guard let url = urlBuilder.build() else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = RequestMethod.POST.rawValue
        
        if let body = self.encodeParameters(parameters: parameters) {
            
            request.httpBody = body
        }
        return request
    }
}
