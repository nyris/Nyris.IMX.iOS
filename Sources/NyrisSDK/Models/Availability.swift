//
//  Availability.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 24/06/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

public struct Availability {
    public let type:AvailabilityType
    public let fromDate:Date
    public let quantity:UInt
}

extension Availability : JsonCodable {
    
    typealias GenericType = Availability
    
    static func decode(json: [String : Any]) -> Availability? {
        guard json.isEmpty == false else {
            return nil
        }
        
        guard let typeValue = json["t"] as? Int else {
            return nil
        }
        
        guard let type = AvailabilityType(rawValue: UInt(typeValue)) else {
            return nil
        }
        
        return Availability(type: type, fromDate: Date(), quantity: UInt(0))
    }
    
    static func decodeArray(json: [String : Any]) -> [Availability] {
        return []
    }
}
