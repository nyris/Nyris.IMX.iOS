//
//  Availability.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 24/06/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

public enum AvailabilityType: UInt {
    case invalid = 0
    case inStock = 1
    case backInStockSoon = 2
    case outOfStock = 3
    case preOrder = 4
    case removed = 5
}
