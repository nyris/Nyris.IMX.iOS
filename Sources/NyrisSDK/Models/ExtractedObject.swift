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
    
    /// The identified object bounding box
    public let region:Rectangle
    
    /// The identified object class e.g: table, bottle...
    public let className:String
    
    private init(confidence:Float, region:Rectangle, className:String) {
        self.confidence = confidence
        self.region = region
        self.className = className
    }
    
    public static func central(to frame:CGRect) -> ExtractedObject {
        let screenYCenter = frame.size.height / 2
        let boxHeight = frame.size.height / 2
        let boxWidth = frame.size.width
        let boxRectangle = CGRect(x: 0,
                                  y: screenYCenter - (boxHeight / 2),
                                  width: boxWidth,
                                  height: boxHeight)
        let confidence:Float = 1.0
        let className = "CentralBox"
        
        let bottom = Float(boxRectangle.origin.y + boxRectangle.size.height)
        let right = Float(boxRectangle.origin.x + boxRectangle.size.width)
        
        let region = Rectangle(top: Float(boxRectangle.origin.y),
                               left: Float(boxRectangle.origin.x),
                               bottom:bottom,
                               right: right)
        
        return ExtractedObject(confidence: confidence,
                               region: region,
                               className: className)
    }
}

extension ExtractedObject : Equatable {
    public static func == (lhs: ExtractedObject, rhs: ExtractedObject) -> Bool {
        return lhs.className == rhs.className &&
        lhs.confidence == rhs.confidence &&
        lhs.region == rhs.region
    }
}