//
//  MockTickerListRepository.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/11/23.
//
import Foundation
import XCAStocksAPI

#if DEBUG
struct MockTickerListRepository: TickerListRepository {
    
    var stubbedLoad: (() async throws -> [Ticker])!
    func load() async throws -> [Ticker] {
        try await stubbedLoad()
    }
    
    func save(_ current: [Ticker]) async throws {}
    
}

#endif
