//
//  Stocks.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/5/23.
//

import Foundation

struct Stock: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
    // Add more details as needed
}
