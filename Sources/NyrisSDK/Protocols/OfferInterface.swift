//
//  OfferModel.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 24/06/2017.
//  Copyright © 2017 nyris. All rights reserved.
//

import Foundation

protocol OfferInterface {
    
    var id: String { get }
    var etag: String? { get }
    
    var title: String { get }
    var description: String? { get }
    var merchant: String? { get }
    var price: Price { get }
    var salePrice: Price? { get }
    var availability: Availability? { get }
    var link: String? { get }
    
    /*
     @SerializedName("title")
     protected String title;
     @SerializedName("desc")
     protected String description;
     @SerializedName("mer")
     protected String merchant;
     @SerializedName("p")
     protected Price price;
     @SerializedName("sp")
     protected SalePrice salePrice;
     @SerializedName("av")
     protected Availability availability;
     @SerializedName("l")
     protected String link;
 */
}
