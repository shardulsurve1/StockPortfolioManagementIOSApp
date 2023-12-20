//
//  MockStocksAPI.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/11/23.
//

import Foundation
import XCAStocksAPI

#if DEBUG
struct MockStocksAPI: StocksAPI {
    
    var stubbedSearchTickersCallback: (() async throws -> [Ticker])!
    func searchTickers(query: String, isEquityTypeOnly: Bool) async throws -> [Ticker] {
        try await stubbedSearchTickersCallback()
    }
    
    var stubbedFetchQuotesCallback: (() async throws -> [Quote])!
    func fetchQuotes(symbols: String) async throws -> [Quote] {
        try await stubbedFetchQuotesCallback()
    }
    
}
#endif
