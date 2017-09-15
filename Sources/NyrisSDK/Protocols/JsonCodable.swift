//
//  JsonCodable.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 24/06/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

/// Json decode protocol
protocol JsonCodable {
    associatedtype GenericType
    
    /// Decode single T instance from the given Json
    ///
    /// - Parameter json: json to be decoded
    /// - Returns: parsed model or nil if fails
    static func decode(json:[String:Any]) -> GenericType?
    
    /// Decode List of T instances from the given Json
    ///
    /// - Parameter json: json to be decoded
    /// - Returns: List of parsed models, or empty list if fails
    static func decodeArray(json:[String:Any]) -> [GenericType]
}
