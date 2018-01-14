//
//  ExtractedObject.swift
//  Nyris.IMX.iOS
//
//  Created by MOSTEFAOUI Anas on 09/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation

public struct ExtractedObject : Codable {
    public let confidence:Float
    public let region:Rectangle
    public let className:String
    //public let vector:AnyObject?
}
