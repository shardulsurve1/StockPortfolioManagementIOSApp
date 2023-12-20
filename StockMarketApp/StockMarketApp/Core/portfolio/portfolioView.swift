//
//  portfolioView.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/4/23.
//

import SwiftUI
import FinnhubSwift

struct StockHolding: Identifiable {
    let id = UUID()
    let symbol: String
    let companyName: String
    var quantity: Int
    let purchasePrice: Double
    var currentPrice: Double = 1.0
}

struct portfolioView: View {
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @State private var totalInvestedValue: Double = 0.0
    @State private var totalCurrentValue: Double = 0.0
    @State private var profitLossAmount: Double = 0.0
    @State private var profitLossPercentage: Double = 0.0
    @State private var timer: Timer?
    @State private var isSellSheetPresented = false
    @State private var selectedHolding: StockHolding?
    

    @State private var stockHoldings: [StockHolding] = []


    
    var body: some View {
           NavigationView {
               VStack {
                   Text("My Portfolio")
                       .font(.system(size: 24, weight: .bold))
                       .padding(20)

                   HStack {
                       VStack(alignment: .leading, spacing: 8) {
                           Text("Invested Amount")
                               .font(.headline)
                               .fontWeight(.bold)

                           Text("$\(String(format: "%.2f", totalInvestedValue))")
                               .foregroundColor(.black)
                               .font(.subheadline)
                       }

                       Spacer()

                       VStack(alignment: .trailing, spacing: 8) {
                           Text("Current Value")
                               .font(.headline)
                               .fontWeight(.bold)

                           Text("$\(String(format: "%.2f", totalCurrentValue))")
                               .foregroundColor(totalCurrentValue >= totalInvestedValue ? .green : .red)
                               .font(.subheadline)
                       }
                   }
                   .padding()
                   .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.white))

                   Divider()

                   HStack {
                       VStack(alignment: .leading, spacing: 8) {
                           Text("Profit/Loss")
                               .font(.headline)
                               .fontWeight(.bold)

                           Text("$\(String(format: "%.2f", profitLossAmount))")
                               .foregroundColor(profitLossAmount >= 0 ? .green : .red)
                               .font(.subheadline)
                       }
                       Spacer()

                       VStack(alignment: .trailing, spacing: 8) {
                           Text("Percentage Change")
                               .font(.headline)
                               .fontWeight(.bold)

                           Text("\(String(format: "%.2f", profitLossPercentage))%")
                               .foregroundColor(profitLossAmount >= 0 ? .green : .red)
                               .font(.subheadline)
                       }
                   }
                   .padding()
                   .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.white))

                   List(stockHoldings) { holding in
                       StockRowPortfolio(holding: holding)
                           .contextMenu {
                               Button("Sell") {
                                   selectedHolding = holding
                                   isSellSheetPresented = true
                               }
                           }
                   }
               }
               .onAppear {
                   Task {
                       await portfolioViewModel.fetchUserPortfolio()
                       stockHoldings = portfolioViewModel.portfolioItems.map {
                           StockHolding(symbol: $0.symbol, companyName: "", quantity: $0.quantity, purchasePrice: Double($0.averageCost))
                       }
                       fetchRealTimePrices()
                       startTimer()
                   }
               }
               .onDisappear {
                   stopTimer()
               }
               .navigationBarTitle("Portfolio", displayMode: .inline)
               .sheet(isPresented: $isSellSheetPresented) {
                   if let selectedHolding = selectedHolding {
                       SellStockSheet(holding: selectedHolding) { quantity in
                           sellStock(holding: selectedHolding, quantity: quantity)
                           isSellSheetPresented = false
                       }
                   }
               }
           }
       }
    
    

    
    func startTimer() {
            // Set the timer to refresh every 60 seconds (adjust as needed)
            timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                fetchRealTimePrices()
            }
        }

    func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
    
    func sellStock(holding: StockHolding, quantity: Int) {
        // Assume you have a function in your PortfolioViewModel to handle the stock sale
        portfolioViewModel.sellStock(symbol: holding.symbol, quantity: quantity)

        // Update the local stockHoldings array and recalculate values
        if let index = stockHoldings.firstIndex(where: { $0.id == holding.id }) {
            if stockHoldings[index].quantity > quantity {
                // If there are remaining stocks, update the quantity
                stockHoldings[index].quantity -= quantity
            } else {
                // If all stocks are sold, remove the holding from the array
                stockHoldings.remove(at: index)
            }
            recalculateValues()
        }
    }

    func fetchRealTimePrices() {
            Task {
                for index in stockHoldings.indices {
                    let symbol = stockHoldings[index].symbol
                    do {
                        let realTimePrice = try await getRealTimePrice(for: symbol)
                        stockHoldings[index].currentPrice = realTimePrice
                    } catch {
                        print("Error fetching real-time price for \(symbol): \(error)")
                    }
                }

                recalculateValues()
            }
        }

        func recalculateValues() {
            totalInvestedValue = stockHoldings.reduce(0) { $0 + ($1.purchasePrice * Double($1.quantity)) }
            totalCurrentValue = stockHoldings.reduce(0) { $0 + ($1.currentPrice * Double($1.quantity)) }
            print("total current value \(totalCurrentValue)")
            profitLossAmount = totalCurrentValue - totalInvestedValue
            profitLossPercentage = totalInvestedValue != 0 ? (profitLossAmount / totalInvestedValue) * 100 : 0.0
        }
    
    
    func getRealTimePrice(for symbol: String) async throws -> Double {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                FinnhubClient.quote(symbol: symbol) { result in
                    switch result {
                    case let .success(data):
                        let currentPrice = data.current
                        continuation.resume(returning: Double(currentPrice))
                    case let .failure(.invalidData):
                        continuation.resume(throwing: RealTimePriceError.invalidData)
                    case let .failure(.networkFailure(error)):
                        continuation.resume(throwing: RealTimePriceError.networkFailure(error))
                    }
                }
            }
        }
    }
    
    enum RealTimePriceError: Error {
        case invalidData
        case networkFailure(Error)
    }
}




struct StockRowPortfolio: View {
    var holding: StockHolding

    var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(holding.symbol) - \(holding.companyName)")
                        .font(.headline)

                    Text("Quantity: \(holding.quantity)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("Invested: $\(String(format: "%.2f", holding.purchasePrice * Double(holding.quantity)))")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
}


struct SellStockSheet: View {
    @State private var sellQuantity: String = ""
    let holding: StockHolding
    let onSell: (Int) -> Void

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Quantity to Sell", text: $sellQuantity)
                            .keyboardType(.numberPad)
                    }
                }

                Button("Sell") {
                    if let quantity = Int(sellQuantity) {
                        onSell(quantity)
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
            }
            .navigationTitle("Sell \(holding.symbol)")
            .navigationBarItems(trailing: Button("Cancel") {
                sellQuantity = ""
                onSell(0) // Cancel the sale
            })
        }
    }
}


struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        portfolioView()
            .environmentObject(PortfolioViewModel()) // Inject the PortfolioViewModel
    }
}


#Preview {
    portfolioView()
}


//
//func sellStock(_ holding: StockHolding, quantity: Int) {
//    
//    selectedStockForSale = holding
//    isSellAlertPresented = true
//    portfolioViewModel.sellStock(symbol: holding.symbol, quantity: quantity)
//       // You may want to refresh your data or UI here after selling
//       // For example, you could fetch the updated portfolio or recalculate values
//       fetchRealTimePrices()
//       recalculateValues()
//   }
