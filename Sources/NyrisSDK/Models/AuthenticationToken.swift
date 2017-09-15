//
//  AuthenticationToken.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 22/04/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

/// AuthenticationToken
public struct AuthenticationToken {
    
    public private(set) var token:String
    public private(set) var tokenExpiration:Int
    public private(set) var lastUpdate:Date
    
    public var isExpired : Bool {
        let expirationTimeStamp = Int(lastUpdate.timeIntervalSince1970) + tokenExpiration
        let currentTimeStamp = Int(Date().timeIntervalSince1970)
        return (currentTimeStamp - expirationTimeStamp) > 0
    }
    
    init(token:String, tokenExpiration:Int, updatedAt:Date) {
        self.token = token
        self.tokenExpiration = tokenExpiration
        self.lastUpdate = updatedAt
    }
    
    func saveToLocalStore() {
        let store = UserDefaults.standard
        store.set(self.token, forKey: "tokenKey")
        store.set(self.tokenExpiration, forKey: "tokenExpire")
        store.set(self.lastUpdate, forKey: "createdAt")
    }
    
    static func parse(data:Data) -> AuthenticationToken? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                return AuthenticationToken.parse(json: json)
            }
            return nil
        } catch {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    static func parse(json:[String:Any]) -> AuthenticationToken? {
        guard json.isEmpty == false else {
            return nil
        }
        
        guard
            json["token_type"] as? String != nil ,
            let tokenString = json["access_token"] as? String,
            let expireInterval = json["expires_in"] as? Int else {
                return nil
        }
        return AuthenticationToken(token: tokenString, tokenExpiration: expireInterval, updatedAt: Date())
    }
    
    public static func loadFromLocalStore() -> AuthenticationToken? {
        let store = UserDefaults.standard
        
        let tokenExpireTime = store.integer(forKey: "tokenExpire")
        guard let createdAtTime = store.object(forKey: "createdAt") as? Date else {
            return nil
        }
        guard let tokenString = store.string(forKey: "tokenKey"), tokenString.isEmpty == false else {
            return nil
        }
        
        return AuthenticationToken(token: tokenString,
                                   tokenExpiration: tokenExpireTime,
                                   updatedAt:createdAtTime)
    }
    
}
