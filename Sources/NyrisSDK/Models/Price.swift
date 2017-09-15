//
//  Price.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUI Anas on 28/06/2017.
//

import Foundation

public struct Price {
    public let currency:String
    public let valueExludingTax:Float
    public let valueIncludingTax:Float
    public let taxRates:Float?
    
    public var digitalValueIncludingTax:Float {
        return valueIncludingTax / 100
    }
    
    public var digitalValueExludingTax:Float {
        return valueExludingTax / 100
    }
    
    public var calculatedTaxRates:Float {
        guard taxRates == nil else {
            return taxRates!
        }
        return roundf( (valueIncludingTax / valueExludingTax) - 1 )
    }
    
    public var taxes:Float {
        return (valueIncludingTax - valueExludingTax) / 100
    }
}

/// String format extension
extension Price {
    public var currencySymbol: String? {
        let locale = NSLocale(localeIdentifier: currency.trimmingCharacters(in: .whitespacesAndNewlines))
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: currency)
    }
    
    public func toString(includeTaxe:Bool) -> String? {
        let value = includeTaxe == true ? self.digitalValueIncludingTax : self.digitalValueExludingTax
        let formatedPrice = self.priceFormater().string(from: value as NSNumber)
        return formatedPrice
    }
    
    private func priceFormater() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = self.currency
        if let currencySymbol = self.currencySymbol {
            formatter.currencySymbol = currencySymbol
        }
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .currencyAccounting
        formatter.locale = nil
        return formatter
    }
}

extension Price : JsonCodable {
    
    typealias GenericType = Price
    
    static func decode(json: [String : Any]) -> Price? {
        
        guard json.isEmpty == false else {
            return nil
        }
        
        guard let currency = json["c"] as? String else {
            return nil
        }
        
        guard let valueExludingTax = json["ve"] as? Float else {
            return nil
        }
        
        guard let valueIncludingTax = json["vi"] as? Float else {
            return nil
        }
        
        var taxRate:Float?
        if let taxRatesValue = json["t"] as? Float {
            taxRate = taxRatesValue
        }
        
        return Price(currency: currency,
                     valueExludingTax: valueExludingTax,
                     valueIncludingTax: valueIncludingTax,
                     taxRates: taxRate)
    }
    
    static func decodeArray(json: [String : Any]) -> [Price] {
        return []
    }
}
