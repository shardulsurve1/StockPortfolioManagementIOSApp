import SwiftUI
import FinnhubSwift

struct stocksView: View {

    let top30StockSymbols = ["AAPL", "GOOGL", "AMZN", "TSLA", "MSFT", /* Add more symbols as needed */]

    @State private var stocks: [CompanySymbolWithPrice] = []
    @State private var filteredStocks: [CompanySymbolWithPrice] = []
    @EnvironmentObject var watchlistViewModel: WatchlistViewModel
    @EnvironmentObject var authlistViewModel: AuthViewModel
    @State private var searchText = ""
    @State private var searchedStocks: [StockSearchResult] = []
    let stockSearchService = StockSearchService()
    

    var body: some View {
           NavigationView {
               VStack {
                   SearchBar(
                       text: $searchText,
                       placeholder: "Search Stocks",
                       onCommit: {
                           // Call searchStocks when the user presses Enter
                           searchStocks(query: searchText)
                       },
                       onCancel: {
                           // Call fetchTop30Stocks when the cancel button is tapped
                           fetchTop30StocksData()
                       }
                   )

                   if searchedStocks.isEmpty {
                       List(stocks, id: \.symbol) { stock in
                           NavigationLink(destination: StockDetailView(symbol: stock.symbol)) {
                               StockRow(stock: stock)
                                   .contextMenu {
                                       Button(action: {
                                           
                                           Task{
                                              await addToWatchlist(stock: stock)
                                           }
                                           // Handle adding the stock to the watchlist
                                          
                                       }) {
                                           Text("Add to Watchlist")
                                           Image(systemName: "bookmark.fill")
                                       }
                                   }
                           }
                       }
                       
                       .onAppear {
                           fetchTop30StocksData()
                       }
                   } else {
                       // Display the searched stocks using StockRow
                       List(searchedStocks, id: \.symbol) { stock in
                           let convertedStock = convertToCompanySymbolWithPrice(stock)
                           NavigationLink(destination: StockDetailView(symbol: stock.symbol)) {
                               StockRow(stock: convertedStock)
                                   .contextMenu {
                                       Button(action: {
                                           Task{
                                              await addToWatchlist(stock: convertedStock)
                                           }
                                       }) {
                                           Text("Add to Watchlist")
                                           Image(systemName: "bookmark.fill")
                                       }
                                   }
                           }
                       }
                   }
               }
               .navigationTitle("Top Stocks")
           }
       }

    
    private func convertToCompanySymbolWithPrice(_ searchResult: StockSearchResult) -> CompanySymbolWithPrice {
            return CompanySymbolWithPrice(
                symbol: searchResult.symbol,
                currentPrice: searchResult.price,
                previousClose: nil,  // You might want to set this value appropriately
                nameOfStock: searchResult.name
            )
        }
    
    
    // Function to add the selected stock to the watchlist
    private func addToWatchlist(stock: CompanySymbolWithPrice) async {
           do {
               try await authlistViewModel.addToWatchlist(stock: stock)
               print("Stock added to watchlist: \(stock.symbol)")
           } catch {
               print("Failed to add stock to watchlist with error: \(error.localizedDescription)")
           }
       }
    
    private func searchStocks(query: String) {
            stockSearchService.searchStock(query: query) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        searchedStocks = result
                        
                    }
                } else if let error = error {
                    print("Error searching stocks: \(error)")
                }
            }
        }



    private func fetchTop30StocksData() {
        top30StockSymbols.forEach { symbol in
            FinnhubClient.quote(symbol: symbol) { quoteResult in
                switch quoteResult {
                case let .success(quoteData):
                    FinnhubClient.companyProfile2(symbol: symbol) { profileResult in
                        switch profileResult {
                        case let .success(profileData):
                            DispatchQueue.main.async {
                                let stockWithPrice = CompanySymbolWithPrice(
                                    symbol: symbol,
                                    currentPrice: Double(quoteData.current ?? 0.0),
                                    previousClose: Double(quoteData.previousClose ?? 0.0),
                                    nameOfStock: profileData.name ?? ""
                                )
                                self.stocks.removeAll { $0.symbol == symbol }
                                self.stocks.append(stockWithPrice)
                                self.filterStocks()
                            }
                        case .failure(.invalidData):
                            print("Invalid profile data")
                        case let .failure(.networkFailure(error)):
                            print(error)
                        }
                    }
                case .failure(.invalidData):
                    print("Invalid quote data")
                case let .failure(.networkFailure(error)):
                    print(error)
                }
            }
        }
    }


    private func filterStocks() {
            if searchText.isEmpty {
                // Sort stocks alphabetically by symbol before updating the filteredStocks array
                filteredStocks = stocks.sorted { $0.symbol < $1.symbol }
            } else {
                // Filter and sort the stocks by symbol
                filteredStocks = stocks
                    .filter { $0.symbol.lowercased().contains(searchText.lowercased()) }
                    .sorted { $0.symbol < $1.symbol }
            }
        }
    }



// Modify StockRow
struct StockRow: View {
    var stock: CompanySymbolWithPrice
    @EnvironmentObject var watchlistViewModel: WatchlistViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.headline)
                
                Text(stock.nameOfStock ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()

            if let currentPrice = stock.currentPrice {
                Text(String(format: "%.2f", currentPrice))
                    .font(.headline)
                    .foregroundColor(currentPrice > (stock.previousClose ?? 0.0) ? .green : .red)
            }

            // Add a button to add/remove from the watchlist
            Button(action: {
                if watchlistViewModel.isSymbolInWatchlist(stock.symbol) {
                    // Symbol is in watchlist, remove it
                    watchlistViewModel.removeFromWatchlist(symbol: stock.symbol)
                } else {
                    // Symbol is not in watchlist, add it
                    watchlistViewModel.addToWatchlist(symbol: stock.symbol,name: stock.nameOfStock ?? "",lastPrice: stock.currentPrice ?? 0)
                }
            }) {
                Image(systemName: watchlistViewModel.isSymbolInWatchlist(stock.symbol) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}

//-------------------------------------------------

struct StockDetailView: View {
    var symbol: String
    @State private var stockDetails: CompanyProfile?
    @State private var quoteDetails: Quote?
    @State private var quantity: Int = 1
    @State private var showAlert = false
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .center, spacing: 8) {
                    Text(stockDetails?.name ?? "Stock Detail")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                       

                    HStack {
                        Text(symbol)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            
                    }
                    Spacer()

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Currency")
                                .font(.headline)
                                .fontWeight(.bold)
                                
                            Text(stockDetails?.currency ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                
                        }

                        Spacer()

                        VStack(spacing: 4) {
                            Text("Exchange")
                                .font(.headline)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text(stockDetails?.exchange ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Divider()

                if let stockDetails = stockDetails, let quoteDetails = quoteDetails {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Price")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text(formatCurrency(quoteDetails.current))
                                    .font(.subheadline)
                                    .foregroundColor(quoteDetails.current > quoteDetails.previousClose ? .green : .red)
                                    
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Percentage Change")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text(formatPercentageChange(quoteDetails))
                                    .font(.subheadline)
                                    .foregroundColor(quoteDetails.current > quoteDetails.previousClose ? .green : .red)
                                   
                            }
                        }

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Low Price")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text(formatCurrency(quoteDetails.low))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                   
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("High Price")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text(formatCurrency(quoteDetails.high))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                   
                            }
                        }

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Open Price")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text(formatCurrency(quoteDetails.open))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                   
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Previous Close")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text(formatCurrency(quoteDetails.previousClose))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Quantity")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Stepper(value: $quantity, in: 1...100) {
                                    Text("\(quantity)")
                                }
                            }
                            
                            HStack {
                                
                                Spacer()
                                
                                
                                Button(action: {
                                         buyStock()
                                    
                                   
                                    
                                }) {
                                    
                                    Text("Buy Stock")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            fetchStockDetails()
            fetchQuoteDetails()
        }
        .navigationBarTitle("", displayMode: .inline)
    }

    private func fetchStockDetails() {
        FinnhubClient.companyProfile2(symbol: symbol) { result in
            switch result {
            case let .success(data):
                DispatchQueue.main.async {
                    self.stockDetails = data
                }
            case .failure(.invalidData):
                print("Invalid data")
            case let .failure(.networkFailure(error)):
                print(error)
            }
        }
    }
    
    private func buyStock()  {
           guard let quoteDetails = quoteDetails else { return }

           let purchaseAmount = Float(quantity) * (quoteDetails.current ?? 0.0)

           // Assume you have a function in your PortfolioViewModel to handle the stock purchase
         portfolioViewModel.purchaseStock(symbol: symbol, quantity: quantity, purchaseAmount: purchaseAmount)
        
        print("buy stock method complete")

           showAlert = true
       }

    private func fetchQuoteDetails() {
        FinnhubClient.quote(symbol: symbol) { result in
            switch result {
            case let .success(data):
                DispatchQueue.main.async {
                    self.quoteDetails = data
                }
            case .failure(.invalidData):
                print("Invalid data")
            case let .failure(.networkFailure(error)):
                print(error)
            }
        }
    }

    private func formatCurrency(_ value: Float?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = stockDetails?.currency
        return formatter.string(from: NSNumber(value: value ?? 0.0)) ?? "\(value ?? 0.0)"
    }

    private func formatPercentageChange(_ quoteDetails: Quote) -> String {
        let percentageChange = ((quoteDetails.current - quoteDetails.previousClose) / quoteDetails.previousClose) * 100
        return String(format: "%.2f%%", percentageChange)
    }
}




//--------------------------------------------

struct stocksView_Previews: PreviewProvider {
    static var previews: some View {
        stocksView()
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var onCommit: () -> Void  // Add this line
    var onCancel: () -> Void
    var body: some View {
        HStack {
            TextField(placeholder, text: $text, onEditingChanged: { _ in
                // React to the editing state if needed
            }, onCommit: {
                // Call onCommit closure when the user presses Enter
                onCommit()
            })
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 10)

            Button(action: {
                // Clear the text when the cancel button is tapped
                text = ""
                
                onCancel()
                
                // Dismiss the keyboard
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                onCommit()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
            .opacity(text.isEmpty ? 0 : 1)
        }
    }
}

// Extend CompanySymbol to include currentPrice and previousClose
struct CompanySymbolWithPrice: Identifiable,Codable {
    var id = UUID()
    let symbol: String
    let currentPrice: Double?
    let previousClose: Double?
    let nameOfStock: String?
}


