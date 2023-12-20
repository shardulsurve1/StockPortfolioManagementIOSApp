//
//  WatchlistViewModel.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/12/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore

class WatchlistViewModel: ObservableObject {
    @Published var watchlistItems: [WatchlistItem] = []

    
    func isSymbolInWatchlist(_ symbol: String) -> Bool {
           return watchlistItems.contains { $0.symbol == symbol }
       }

    // have to change current price
    func addToWatchlist(symbol: String, name:String, lastPrice:Double) {
           if !watchlistItems.contains(where: { $0.symbol == symbol }) {
               // Create a WatchlistItem or use your own logic to initialize it
               let newItem = WatchlistItem(symbol: symbol,nameOfStock: name,previousClose: lastPrice, currentPrice: lastPrice)
               watchlistItems.append(newItem)
           }
       }

       func removeFromWatchlist(symbol: String) {
           watchlistItems.removeAll { $0.symbol == symbol }
       }
}

