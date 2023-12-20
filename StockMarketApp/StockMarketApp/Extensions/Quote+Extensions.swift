//
//  Quote+Extensions.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/10/23.
//

import Foundation
import XCAStocksAPI

extension Quote {
    
    var regularPriceText: String? {
        Utils.format(value: regularMarketPrice)
    }
    
    var regularDiffText: String? {
        guard let text = Utils.format(value: regularMarketChange) else { return nil }
        return text.hasPrefix("-") ? text : "+\(text)"
    }
    
}
