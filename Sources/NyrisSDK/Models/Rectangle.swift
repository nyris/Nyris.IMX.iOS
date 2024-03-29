//
//  Rectangle.swift
//  Nyris.IMX.iOS
//
//  Created by MOSTEFAOUI Anas on 12/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation
import UIKit

public struct Rectangle : Codable {
    public private(set) var top:Float
    public private(set) var left:Float
    public private(set) var bottom:Float
    public private(set) var right:Float
    
    /// Create a Rectangle from CGRect
    ///
    /// - Parameter rect: CGRect
    /// - Returns: Rectangle
    public static func fromCGRect(rect:CGRect) -> Rectangle {
        return Rectangle(top:  Float(rect.origin.y),
                         left: Float(rect.origin.x),
                         bottom: Float(rect.origin.y + rect.size.height),
                         right: Float(rect.origin.x + rect.size.width))
    }
    
    public func normalized(sourceFrame:CGRect) -> CGRect {
        let rect = self.toCGRect()
        return CGRect(x: rect.origin.x / CGFloat(sourceFrame.size.width),
                      y: rect.origin.y / CGFloat(sourceFrame.size.height),
                      width: rect.size.width / CGFloat(sourceFrame.size.width),
                      height: rect.size.height / CGFloat(sourceFrame.size.height))
    }
    
    public func toCGRect() -> CGRect {
        // the API Rectangle define 4 points for a rectangle
        // to project these point to the common CGRect we need to add position value e.g:
        // rectangle bottom = CGRect.X + CGRect.Width
        // rectangle right = CGRect.X + CGRect.Width
        // e.g:
        // rectangle : top = 40, left = 30, bottom = 120, right = 140
        // CGRect : x = 30, y = 40, width = 110 (140-30), height = 80 (120-40)
        //
        // to convert from rectangle to CGRect
        //      - x = left
        //      - y = top
        //      - width = right - left
        //      - Height = bottom - top
        //
        // to convert from CGRect to rectangle
        //      - left = x
        //      - top = y
        //      - right = x + width
        //      - bottom = y + height
        //
        return CGRect(x: CGFloat(left),
                      y: CGFloat(top),
                      width: CGFloat(right)  - CGFloat(left),
                      height: CGFloat(bottom) - CGFloat(top))
    }
}

extension Rectangle : Equatable {
    public static func == (lhs: Rectangle, rhs: Rectangle) -> Bool {
        return lhs.top == rhs.top &&
        lhs.bottom == rhs.bottom &&
        lhs.left == rhs.left &&
        lhs.right == rhs.right
    }
}

extension CGRect {
    public func projectOn(projectionFrame:CGRect, from baseFrame:CGRect) -> CGRect {
        let scaledRectangle = ImageHelper.applyRectProjection(
            on: self,
            from: baseFrame,
            to: projectionFrame,
            padding: 0,
            navigationHeaderHeight: 0)
        
        return scaledRectangle
    }
    public func isNormalized() -> Bool {
        let normalizedRange = 0.0...1.0
        return normalizedRange.contains(origin.x) &&
               normalizedRange.contains(origin.y) &&
               normalizedRange.contains(size.height) &&
               normalizedRange.contains(size.width)
    }
}
