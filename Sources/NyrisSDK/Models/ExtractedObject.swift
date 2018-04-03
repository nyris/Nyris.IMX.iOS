//
//  ExtractedObject.swift
//  Nyris.IMX.iOS
//
//  Created by MOSTEFAOUI Anas on 09/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//
import Foundation
import UIKit

public struct ExtractedObject : Codable {
    public let confidence:Float
    /// The identified object bounding box
    public let region:Rectangle
    /// The identified object class e.g: table, bottle...
    public let className:String
    // keep a referance to the frame from where this has been extracted
    public var extractionFromFrame:CGRect?
    
    private enum CodingKeys: String, CodingKey {
        case confidence
        case region
        case className
    }
    
    private init(confidence:Float, region:Rectangle, className:String, extractionFromFrame:CGRect?) {
        self.confidence = confidence
        self.region = region
        self.className = className
        self.extractionFromFrame = extractionFromFrame
    }
}

// projection extension
extension ExtractedObject {
    
    /// Project the extracted object frorm baseFrame to projectionFrame
    ///
    /// - Parameters:
    ///   - projectionFrame: The frame to project to. usualy this is the display destination
    ///   - baseFrame: the base frame from where the extracted object has been extracted
    /// - Returns: ExtractedObject
    public func projectOn(projectionFrame:CGRect, from baseFrame:CGRect) -> ExtractedObject {
        
        let rectangle = self.region.toCGRect()
        let projectedRectangle = rectangle.projectOn(projectionFrame: projectionFrame,
                                                     from: baseFrame)
        
        let projectedRegion = Rectangle.fromCGRect(rect: projectedRectangle)
        let projectedBox = ExtractedObject(confidence: self.confidence,
                                           region: projectedRegion,
                                           className: self.className,
                                           extractionFromFrame: projectionFrame)
        return projectedBox
    }
}

// Generate new ExtractedObject methods
extension ExtractedObject {
    
    public func withRegion(region:Rectangle) -> ExtractedObject {
        let newObject = ExtractedObject(confidence: self.confidence, region: region, className: self.className, extractionFromFrame: self.extractionFromFrame)
        return newObject
    }
    
    /// Create a dummy ExtractedObject centred to the given frame
    ///
    /// - Parameter frame: Frame
    /// - Returns: ExtractedObject
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
                               className: className,
                               extractionFromFrame: frame)
    }
}

extension ExtractedObject : Equatable {
    public static func == (lhs: ExtractedObject, rhs: ExtractedObject) -> Bool {
        return lhs.className == rhs.className &&
        lhs.confidence == rhs.confidence &&
        lhs.region == rhs.region
    }
}
