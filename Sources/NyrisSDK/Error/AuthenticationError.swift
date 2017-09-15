//
//  AuthenticationError.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 23/04/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

public enum AuthenticationError : Error {
    case invalidCredential(message:String)
    case invalidToken(message:String)
}
