//
//  PortfolioViewModel.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/13/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore

@MainActor
class PortfolioViewModel: ObservableObject {
    @Published var portfolioItems: [PortfolioItem] = []
    @EnvironmentObject var authViewModel: AuthViewModel
    

    // Function to purchase stock and update the portfolio
    func purchaseStock(symbol: String, quantity: Int, purchaseAmount: Float) {
        let existingItemIndex = portfolioItems.firstIndex { $0.symbol == symbol }

        if let index = existingItemIndex {
            // Stock already exists in the portfolio, update the quantity and average cost
            var existingItem = portfolioItems[index]
            let totalCost = existingItem.averageCost * Float(existingItem.quantity) + purchaseAmount
            let newQuantity = existingItem.quantity + quantity
            existingItem.averageCost = totalCost / Float(newQuantity)
            existingItem.quantity = newQuantity
            portfolioItems[index] = existingItem

        } else {
            // Stock doesn't exist in the portfolio, add a new item
            let newItem = PortfolioItem(symbol: symbol, quantity: quantity, averageCost: purchaseAmount / Float(quantity))
            portfolioItems.append(newItem)
        }
        
        Task{
            await savePortfolioToFirestore()
        }
        
        
    }
    
    // Fetch user-specific portfolio from Firestore
    func fetchUserPortfolio() async {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let documentSnapshot = try await Firestore.firestore().collection("userPortfolio").document(uid).getDocument()

            guard let data = try documentSnapshot.data(),
                  let portfolioData = data["portfolio"] as? [[String: Any]] else {
                return
            }

            portfolioItems = try portfolioData.compactMap { item in
                try Firestore.Decoder().decode(PortfolioItem.self, from: item)
            }
        } catch {
            print("Error fetching user portfolio: \(error.localizedDescription)")
        }

   
    }


    private func savePortfolioToFirestore() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let jsonData = try JSONEncoder().encode(portfolioItems)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])

            guard let portfolioData = jsonObject as? [Any] else {
                print("Error converting portfolio data to array")
                return
            }

            try await Firestore.firestore().collection("userPortfolio").document(uid).setData(["portfolio": portfolioData])
        } catch {
            print("Error saving user portfolio: \(error.localizedDescription)")
        }
    }
    
    private func fetchUserPortfolioD() async throws -> [PortfolioItem] {
           // Implement your logic to fetch the user's portfolio from Firestore
           // and return an array of PortfolioItem
           // This is a placeholder, you need to replace it with your actual implementation
           let querySnapshot = try await Firestore.firestore().collection("userPortfolio").document("user_id").collection("stocks").getDocuments()
           let portfolioItems = try querySnapshot.documents.compactMap { document in
               try document.data(as: PortfolioItem.self)
           }
           return portfolioItems
       }
    
    private func saveUserPortfolio(_ portfolio: [PortfolioItem]) async throws {
            // Implement your logic to save the user's portfolio to Firestore
            // This is a placeholder, you need to replace it with your actual implementation
            let userDocument = Firestore.firestore().collection("userPortfolio").document("user_id")
            for item in portfolio {
                try await userDocument.collection("stocks").document(item.symbol).setData(from: item)
            }
        }
    
    func sellStock(symbol: String, quantity: Int) {
            Task {
                do {
                    // Fetch the user's portfolio from Firestore
                    var userPortfolio = try await fetchUserPortfolioD()

                    // Find the stock in the portfolio
                    if let index = userPortfolio.firstIndex(where: { $0.symbol == symbol }) {
                        var stock = userPortfolio[index]

                        // Check if the user has enough quantity to sell
                        guard stock.quantity >= quantity else {
                            print("Error: Not enough quantity to sell")
                            return
                        }

                        // Update the quantity
                        stock.quantity -= quantity

                        // If the quantity becomes zero, remove the stock from the portfolio
                        if stock.quantity == 0 {
                            userPortfolio.remove(at: index)
                        } else {
                            // Otherwise, update the stock in the portfolio
                            userPortfolio[index] = stock
                        }

                        // Save the updated portfolio to Firestore
                        try await saveUserPortfolio(userPortfolio)

                        print("Stock sold successfully: \(symbol), Quantity: \(quantity)")
                    } else {
                        print("Error: Stock not found in the portfolio")
                    }
                } catch {
                    print("Error selling stock: \(error.localizedDescription)")
                }
            }
        }

}

struct PortfolioItem: Identifiable,Codable {
    var id = UUID()
    let symbol: String
    var quantity: Int
    var averageCost: Float
}

