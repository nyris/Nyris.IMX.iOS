//
//  RequestInputMapping.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUIM on 07/11/2022.
//  Copyright © 2022 nyris. All rights reserved.
//

import Foundation

public protocol HeaderMapper {
    func getKey(mappedKey: String) -> String?
}

public struct NyrisHeaderMapping : HeaderMapper {
    public static var `default` : HeaderMapper {
        return NyrisHeaderMapping()
    }
    private let mapping = [
        "api_key" : "X-Api-Key"
    ]
    public func getKey(mappedKey: String) -> String? {
        return mapping[mappedKey]
    }
}
