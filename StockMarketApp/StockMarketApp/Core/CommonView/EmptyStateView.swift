//
//  EmptyStateView.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/10/23.
//

import SwiftUI

struct EmptyStateView: View {
    let text:String
    var body: some View {
        HStack{
            
            Spacer()
            Text(text)
                .font(.headline)
                .foregroundColor(Color(uiColor: .secondaryLabel))
            Spacer()
            
        }
        .padding(64)
        .lineLimit(3)
        multilineTextAlignment(.center)
    }
}

#Preview {
    EmptyStateView(text: "No Data Available")
}
