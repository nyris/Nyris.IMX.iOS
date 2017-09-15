//
//  ImageInfo.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 24/06/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

public struct ImageInfo {
    public let id:String
    public let url:String
}

extension ImageInfo : JsonCodable {
    typealias GenericType = ImageInfo
    
    static func decode(json: [String : Any]) -> ImageInfo? {
        guard json.isEmpty == false else {
            return nil
        }
        
        guard let id = json["id"] as? String else {
            return nil
        }
        
        _ = json["h"] as? Bool
        _ = json["ifid"] as? String
        let url = json["url"] as? String ?? ""
        return ImageInfo(id: id, url: url)
    }
    
    static func decodeArray(json: [String : Any]) -> [ImageInfo] {
        return []
    }
}
