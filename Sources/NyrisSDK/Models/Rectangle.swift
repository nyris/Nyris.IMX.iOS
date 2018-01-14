//
//  Rectangle.swift
//  Nyris.IMX.iOS
//
//  Created by MOSTEFAOUI Anas on 12/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation

public struct Rectangle : Codable {
    let top:Float
    let left:Float
    let bottom:Float
    let right:Float
    
    func toCGRect() -> CGRect {
        return CGRect(x: CGFloat(left),
                      y: CGFloat(top),
                      width: CGFloat(right),
                      height: CGFloat(bottom))
    }
    func matchScreenResolution(screenWidth:CGFloat, screenHeight:CGFloat) -> CGRect {
        let cgRect = self.toCGRect()
        let correctSizeRect = cgRect.applying( CGAffineTransform(scaleX: 1, y: 1) )
        return correctSizeRect
    }
}
