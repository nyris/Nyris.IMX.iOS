//
//  SearchMode.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 03/04/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation

public struct XOptionHeader {
    
    public var exactMode:Bool = true
    public var similarityMode:Bool = true
    public var similarityLimit:UInt = 0
    public var similarityThreshold:Float = -1
    
    public var ocrMode:Bool = true
    public var group:Bool = true
    public var regroupThreshold:Float = -1

    public var limit : Int = 20
    
    init() {
        
    }
    
    public static var `default`:XOptionHeader {
        var xOption = XOptionHeader()
        xOption.exactMode = true
        xOption.ocrMode = true
        xOption.similarityMode = true
        xOption.limit = 20
        return xOption
    }
    
    var header:String {
        
        return ""
    }
}
