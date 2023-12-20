//
//  StockMarketAppApp.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 11/25/23.
//

import SwiftUI
import Firebase

@main
struct StockMarketAppApp: App {
    @StateObject var viewModel = AuthViewModel()
    @StateObject var watchlistModel = WatchlistViewModel()
    @StateObject var realtimeStockViewModel = RealTimeStockViewModel()
    @StateObject var protfolioViewModel = PortfolioViewModel()
    
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(watchlistModel)
                .environmentObject(realtimeStockViewModel)
                .environmentObject(protfolioViewModel)
        }
    }
}
