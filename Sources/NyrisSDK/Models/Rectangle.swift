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
        return CGRect(x: CGFloat(left),
                      y: CGFloat(top) - CGFloat(left),
                      width: CGFloat(right),
                      height: CGFloat(bottom) - CGFloat(top))
    }
    func matchScreenResolution(screenWidth:CGFloat, screenHeight:CGFloat) -> CGRect {
        let cgRect = self.toCGRect()
        let correctSizeRect = cgRect.applying( CGAffineTransform(scaleX: 1, y: 1) )
        return correctSizeRect
    }
}

extension Rectangle : Equatable {
    public static func ==(lhs: Rectangle, rhs: Rectangle) -> Bool {
        return lhs.top == rhs.top &&
        lhs.bottom == rhs.bottom &&
        lhs.left == rhs.left &&
        lhs.right == rhs.right
    }
    
    
}
