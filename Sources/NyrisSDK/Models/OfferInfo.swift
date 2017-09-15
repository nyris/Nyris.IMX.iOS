//
//  OfferInfo.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 24/06/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation
import UIKit

public struct OfferInfo: OfferInterface {
    public let id: String
    public let etag: String?
    public let title: String
    public let description: String?
    public let merchant: String?
    public let price: Price
    public let salePrice: Price?
    public let availability: Availability?
    public let link: String?
    
    public let imageInfo:ImageInfo?
    
    static public func mock() -> OfferInfo {
        let price = Price(currency: "EUR", valueExludingTax: 20, valueIncludingTax: 40, taxRates: 20)
        let availability = Availability(type: .inStock, fromDate: Date(), quantity: 20)
        let imageInfo = ImageInfo(id: "20", url: "https://sc02.alicdn.com/kf/UT8Rzn8X6haXXcUQpbXO/Coke-Coca-10.png")
        return OfferInfo(id: "40", etag: "40",
                         title: "mock Cola", description: "Drink",
                         merchant: "mock Cola", price: price, salePrice: price,
                         availability: availability, link: "https://google.com", imageInfo: imageInfo)
    }
    
    static public func mock( quantity:Int) -> [OfferInfo] {
        var list:[OfferInfo] = []
        for _ in 0..<quantity {
            let offer = OfferInfo.mock()
            list.append(offer)
        }
        return list
    }
}

extension OfferInfo : JsonCodable {
    
    typealias GenericType = OfferInfo
    
    static func decode(json: [String : Any]) -> OfferInfo? {
        guard json.isEmpty == false else {
            return nil
        }
        
        guard let title = json["title"] as? String else {
            return nil
        }
        
        guard let priceJson = json["p"] as? [String:AnyObject],
            let price = Price.decode(json: priceJson)  else {
                return nil
        }
        
        var merchant:String?
        var salePrice:Price?
        var description:String?
        var availability:Availability?
        var imageInfo:ImageInfo?
        
        if let descriptionValue = json["desc"] as? String {
            description = descriptionValue
        }
        
        if let merchantValue = json["mer"] as? String {
            merchant = merchantValue
        }
        
        if let availabilityJson = json["av"] as? [String:AnyObject],
            let availabilityValue = Availability.decode(json:availabilityJson) {
            availability = availabilityValue
        }
        
        if let imageInfoJson = json["img"] as? [String:AnyObject],
            let imageInfoValue = ImageInfo.decode(json:imageInfoJson) {
            imageInfo = imageInfoValue
        }
        
        if let salePriceJson = json["sp"] as? [String:AnyObject],
            let parsedPrice = Price.decode(json: salePriceJson) {
            salePrice = parsedPrice
        }
        
        let link = json["l"] as? String ?? ""
        
        return OfferInfo(id: "", etag: "",
                         title: title, description: description,
                         merchant: merchant, price: price, salePrice: salePrice,
                         availability: availability, link: link, imageInfo: imageInfo)
    }
    
    static func decodeArray(json: [String : Any]) -> [OfferInfo] {
        guard json.isEmpty == false,
            json.keys.contains("offerInfos"),
            let offersListJson = json["offerInfos"] as? [ [String:Any] ] else {
            return []
        }
        var offersList:[OfferInfo] = []
        for offerJson in offersListJson {
            guard let offer = OfferInfo.decode(json: offerJson) else {
                continue
            }
            offersList.append(offer)
        }
        
        return offersList
    }
}
