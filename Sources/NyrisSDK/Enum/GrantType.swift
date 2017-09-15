//
//  GrantType.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 18/04/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

/// Access Granted type provided by the API
public enum GrantType : String {
    
    case clientCredentials = "client_credentials"
    case password = "password"
    case refreshToken = "refresh_token"
    
    static let key:String = "grant_type"
}
