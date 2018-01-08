//
//  Product.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 05/01/2018.
//  Copyright © 2018 nyris. All rights reserved.
//

import Foundation

public struct Offer : Codable {
    public let title:String?
    public let descriptionShort:String?
    public let description:String?
    public let language:String?
    public let brand:String?
    public let catalogNumbers:[String]?
    public let customIds:[String:String]?
    public let keywords:[String]?
    public let categories:[String]?
    public let availability:String?
    public let groupId:String?
    public let price:String?
    public let salePrice:String?
    public let links:OfferLinks?
    public let images:[String]?
    public let metadata:String?
    public let sku:String
    public let score:Float
}

public struct OfferLinks: Codable {
    public let main:String?
    public let mobile:String?
}

public struct OffersResult: Codable {
    public let products:[Offer]
}

