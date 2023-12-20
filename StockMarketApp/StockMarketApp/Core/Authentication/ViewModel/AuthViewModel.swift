//
//  AuthViewModel.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 11/25/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore

protocol AuthenticationFormProtocol{
    var isFormValid: Bool{get}
}
@MainActor
class AuthViewModel : ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var userSpecificData: UserSpecificData?
    @Published var userWatchlistItems: [WatchlistItem] = []

    init() {
        self.userSession = Auth.auth().currentUser

        Task {
            await fetchUser()
        }
    }

    func signIn(withEmail email: String, password: String) async throws {

            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        
    }

    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let ecodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(ecodedUser)
            await fetchUser()
        } catch {
            print("Debug Failed to Create User with Error \(error.localizedDescription)")
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            print("Sign Out Complete")
        } catch {
            print("Sign Out Error with Error \(error.localizedDescription)")
        }
    }

    func deleteAccount() {
        // Implement account deletion logic if needed
    }

    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        print("Debug: current user is \(self.currentUser)")
    }

    // New functions to handle watchlist and portfolio
    func addToWatchlist(stock: CompanySymbolWithPrice) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let watchlistRef = Firestore.firestore().collection("userWatchlist").document(uid).collection("stocks").document(stock.symbol)

        do {
            try await watchlistRef.setData(from: stock)
            print("Stock added to watchlist: \(stock.symbol)")
        } catch {
            print("Failed to add stock to watchlist with error: \(error.localizedDescription)")
        }
    }
    
    
//    func addToPortfolio(stock: CompanySymbolWithPrice, quantity: Int, purchasePrice: Double) async throws {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let portfolioRef = Firestore.firestore().collection("userPortfolio").document(uid).collection("stocks").document(stock.symbol)
//
//        let portfolioData: [String: Any] = [
//            "symbol": stock.symbol,
//            "quantity": quantity,
//            "purchasePrice": purchasePrice,
//            // ... add other stock information as needed
//        ]
//
//        do {
//            try await portfolioRef.setData(portfolioData)
//            print("Stock added to portfolio: \(stock.symbol)")
//        } catch {
//            print("Failed to add stock to portfolio with error: \(error.localizedDescription)")
//        }
//    }
    
    func fetchUserWatchlist() async {
           do {
               guard let uid = userSession?.uid else {
                   print("User is not authenticated.")
                   return
               }

               let watchlistSnapshot = try await Firestore.firestore()
                   .collection("userWatchlist")
                   .document(uid)
                   .collection("stocks")
                   .getDocuments()

               // Map the documents to WatchlistItem
               userWatchlistItems = watchlistSnapshot.documents.compactMap { document in
                   do {
                       let item = try document.data(as: WatchlistItem.self)
                       return item
                   } catch {
                       print("Error decoding WatchlistItem: \(error.localizedDescription)")
                       return nil
                   }
               }
           } catch {
               print("Failed to fetch user's watchlist: \(error.localizedDescription)")
           }
       }
    
    
    func removeFromUserWatchlist(symbol: String) async {
            do {
                guard let uid = userSession?.uid else {
                    print("User is not authenticated.")
                    return
                }

                let watchlistRef = Firestore.firestore()
                    .collection("userWatchlist")
                    .document(uid)
                    .collection("stocks")
                    .document(symbol)

                try await watchlistRef.delete()
                print("Stock removed from user's watchlist: \(symbol)")
            } catch {
                print("Failed to remove stock from user's watchlist: \(error.localizedDescription)")
            }
        }
    
    
   
}

