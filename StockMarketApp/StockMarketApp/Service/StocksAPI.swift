//
//  StocksAPI.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/11/23.
//

import Foundation
import XCAStocksAPI

protocol StocksAPI {
    func searchTickers(query: String, isEquityTypeOnly: Bool) async throws -> [Ticker]
    func fetchQuotes(symbols: String) async throws -> [Quote]
}

extension XCAStocksAPI: StocksAPI {}
