//
//  ImageError.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 02/02/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation

public enum ImageError : Error {
    case invalidSize(message:String)
    case invalidImageData(message:String)
    case resizingFailed(message:String)
    case rotatingFailed(message:String)
}
