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
                                  y: screenYCenter - (boxHeight * 0.5),
                                  width: boxWidth,
                                  height: boxHeight)
        let confidence:Float = 1.0
        let className = "CentralBox"
        let region = Rectangle(top: Float(boxRectangle.origin.y),
                               left: Float(boxRectangle.origin.x),
                               bottom: Float(boxRectangle.size.height),
                               right: Float(boxRectangle.size.width))
        return ExtractedObject(confidence: confidence,
                               region: region,
                               className: className)
    }
}
