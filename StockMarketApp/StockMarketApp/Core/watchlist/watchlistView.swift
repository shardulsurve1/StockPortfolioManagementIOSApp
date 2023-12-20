//
//  watchlistView.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/4/23.
//

import SwiftUI

struct WatchlistItem: Identifiable,Codable {
    var id = UUID()
    let symbol: String
    let nameOfStock: String
    let previousClose: Double
    let currentPrice: Double
    
    // Add more details as needed
}

struct watchlistView: View {
    @State private var searchText = ""
    @EnvironmentObject var watchlistViewModel: WatchlistViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var sortOption = SortOption.defaultSort

    var filteredWatchlist: [WatchlistItem] {
        if searchText.isEmpty {
            return watchlistViewModel.watchlistItems
        } else {
            return watchlistViewModel.watchlistItems.filter { $0.nameOfStock.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var sortedWatchlist: [WatchlistItem] {
            switch sortOption {
            case .alphabetical:
                return filteredWatchlist.sorted { $0.nameOfStock < $1.nameOfStock }
            case .price:
                return filteredWatchlist.sorted { $0.previousClose < $1.previousClose }
            case .defaultSort:
                return filteredWatchlist
            }
        }


    var body: some View {
           NavigationView {
               VStack {
                   Picker("Sort by", selection: $sortOption) {
                       Text("Default").tag(SortOption.defaultSort)
                       Text("Alphabetical").tag(SortOption.alphabetical)
                       Text("Price").tag(SortOption.price)
                   }
                   .pickerStyle(SegmentedPickerStyle())
                   .padding()

                   List {
                       searchView(text: $searchText)

                       ForEach(authViewModel.userWatchlistItems) { item in
                           NavigationLink(destination: StockDetailView(symbol: item.symbol)) {
                               StockRow(stock: CompanySymbolWithPrice(
                                   symbol: item.symbol,
                                   currentPrice: item.previousClose,
                                   previousClose: 0.0, // You can set an appropriate value or leave it as 0.0
                                   nameOfStock: item.nameOfStock
                               ))
                               .contextMenu {
                                   Button(action: {
                                       Task{
                                          await authViewModel.removeFromUserWatchlist(symbol: item.symbol)
                                           await authViewModel.fetchUserWatchlist()
                                       }
                                       
                                   }) {
                                       Text("Remove from Watchlist")
                                       Image(systemName: "bookmark.slash.fill")
                                   }
                               }
                           }
                       }
                   }
               }
               .task {
                   await authViewModel.fetchUserWatchlist()
               }
               .navigationTitle("Watchlist")
           }
       }
   }


enum SortOption {
    case defaultSort
    case alphabetical
    case price
}



struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        watchlistView()
    }
}

#Preview {
    watchlistView()
}
