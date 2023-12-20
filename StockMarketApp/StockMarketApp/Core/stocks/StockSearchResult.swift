//
//  StockSearchResult.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/15/23.
//

import Foundation


struct StockSearchResult {
    let symbol: String
    let name: String
    let price: Double
}

class StockSearchService {
    private let apiKey = "21f341dcc5msh9bd5826242dcc0bp12caa6jsn634e2bafe637"
    private let rapidAPIHost = "real-time-finance-data.p.rapidapi.com"

    func searchStock(query: String, completion: @escaping ([StockSearchResult]?, Error?) -> Void) {
        let urlString = "https://real-time-finance-data.p.rapidapi.com/search?query=\(query)&language=en"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "X-RapidAPI-Key": apiKey,
            "X-RapidAPI-Host": rapidAPIHost
        ]

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "No data received", code: 0, userInfo: nil))
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(SearchResult.self, from: data)
                let stocks = self.extractStocks(from: result)
                completion(stocks, nil)
            } catch {
                completion(nil, error)
            }
        }

        dataTask.resume()
    }

    private func extractStocks(from result: SearchResult) -> [StockSearchResult] {
        var stocks: [StockSearchResult] = []

        if let stockData = result.data?.stock {
            for stock in stockData {
                // Check if the stock is from the US
                if stock.country_code == "US" {
                    // Extract only the stock symbol by removing the exchange symbol
                    let symbolComponents = stock.symbol.components(separatedBy: ":")
                    let stockSymbol = symbolComponents.first ?? stock.symbol

                    let stockResult = StockSearchResult(
                        symbol: stockSymbol,
                        name: stock.name,
                        price: stock.price
                    )

                    // Add the stock result to the array
                    stocks.append(stockResult)
                }
            }
        }

        return stocks
    }

}

struct SearchResult: Codable {
    let data: StockData?

    struct StockData: Codable {
        let stock: [Stock]?

        struct Stock: Codable {
            let symbol: String
            let name: String
            let price: Double
            let country_code: String
        }
    }
}
