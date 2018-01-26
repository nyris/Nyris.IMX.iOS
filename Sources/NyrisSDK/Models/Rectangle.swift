//
//  Rectangle.swift
//  Nyris.IMX.iOS
//
//  Created by MOSTEFAOUI Anas on 12/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation

public struct Rectangle : Codable {
    public let top:Float
    public let left:Float
    public let bottom:Float
    public let right:Float
    
    public func toCGRect() -> CGRect {
        // the API Rectangle define 4 points for a rectangle
        // to project these point to the commun CGRect we need to add position value e.g:
        // rectnagle bottom = CGRect.X + CGRect.Width
        // rectnagle right = CGRect.X + CGRect.Width
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
