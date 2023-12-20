//
//  RealTimeStockViewModel.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/12/23.
//

import Foundation
import Alamofire


struct RealTimeStockData: Decodable {
    let status: String
    let requestId: String
    let data: StockData
}

struct StockData: Decodable {
    let stock: [Stock]
    // Add other data fields as needed
}

struct Stock: Decodable {
    let symbol: String
    let name: String
    let type: String
    let price: Double
    let change: Double
    let changePercent: Double
    let previousClose: Double
    let lastUpdateUTC: String
    let countryCode: String
    let exchange: String
    let exchangeOpen: String
    let exchangeClose: String
    let timezone: String
    let utcOffsetSec: Int
    let currency: String
    let googleMid: String
}

class RealTimeStockViewModel: ObservableObject {
    let apiKey = "YOUR_RAPIDAPI_KEY"
    let baseURL = "https://real-time-finance-data.p.rapidapi.com"

    func fetchRealTimeStockData(query: String, completion: @escaping (Result<RealTimeStockData, Error>) -> Void) {
        let headers: [String: String] = [
            "X-RapidAPI-Key": apiKey,
            "X-RapidAPI-Host": "real-time-finance-data.p.rapidapi.com"
        ]

        let urlString = "\(baseURL)/search?query=\(query)&language=en"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let realTimeStockData = try decoder.decode(RealTimeStockData.self, from: data)
                completion(.success(realTimeStockData))
                print(realTimeStockData)
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

