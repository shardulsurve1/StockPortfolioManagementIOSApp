//
//  ErrorStateView.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/10/23.
//

import SwiftUI

struct ErrorStateView: View {
    let error: String
    var retryCallback: (() -> ())? = nil
    var body: some View {
        HStack{
            Spacer()
            VStack(spacing: 16){
                Text(error)
                if let retryCallback {
                    Button("Retry", action: retryCallback)
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(64)
    }
}

#Preview {
    
    Group{
        ErrorStateView(error: "An Error Occured"){}
            .previewDisplayName("With Retry Button")
        
        ErrorStateView(error: "An Error Occured")
            .previewDisplayName("Without Retry Button")
    }
    
}
