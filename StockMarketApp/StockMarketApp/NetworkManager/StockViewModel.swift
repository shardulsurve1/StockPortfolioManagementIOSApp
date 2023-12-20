//
//  StockViewModel.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/6/23.
//

//import Foundation
//import Alamofire
//
//struct StockData: Decodable {
//    // Define the structure based on the Alpha Vantage API response
//    let metaData: MetaData
//    let timeSeries: [String: TimeSeries]
//
//    private enum CodingKeys: String, CodingKey {
//        case metaData = "Meta Data"
//        case timeSeries = "Time Series (1min)" // Change this based on the actual response key
//    }
//    
//}
//
//struct MetaData: Decodable {
//    let symbol: String
//    let lastRefreshed: String
//
//    // Add other metadata fields as needed
//}
//
//struct TimeSeries: Decodable {
//    let open: String
//    let high: String
//    let low: String
//    let close: String
//    let volume: String
//
//    // Add other time series fields as needed
//}
//
//
//class StockViewModel: ObservableObject {
//    let apiKey = "0R77D3R5M9PZ4E2K"
//    let baseURL = "https://www.alphavantage.co/query"
//
//    func fetchStockData(symbol: String, completion: @escaping (Result<StockData, Error>) -> Void) {
//        let parameters: [String: Any] = [
//            "function": "TIME_SERIES_INTRADAY",
//            "symbol": symbol,
//            "interval": "1min", // or your preferred interval
//            "apikey": apiKey
//        ]
//
//        AF.request(baseURL, method: .get, parameters: parameters)
//            .validate()
//            .responseDecodable(of: StockData.self) { response in
//                switch response.result {
//                case .success(let stockData):
//                    completion(.success(stockData))
//                    print(stockData)
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//    }
//}

