//
//  RequestError.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 23/04/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

public enum RequestError : Error {
    case invalidData(message:String)
    case invalidHTTPCode(message:String, status:Int)
    case invalidEndpoint(message:String)
    case unreachableNetwork(message:String)
    case requestFailed
    case parsingFailed
}
