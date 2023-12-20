//
//  TickerListRowData.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/10/23.
//

import Foundation

typealias PriceChange = (price: String, change: String)

struct TickerListRowData {
    
    enum RowType {
        case main
        case search(isSaved: Bool, onButtonTapped: () -> ())
    }
    
    let symbol: String
    let name: String?
    let price: PriceChange?
    let type: RowType
    
}
