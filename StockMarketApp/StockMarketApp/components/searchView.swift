//
//  searchView.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/5/23.
//

import SwiftUI

struct searchView: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search Stocks", text: $text)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color(.systemGray6)))
                .padding(.horizontal, 15)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

#Preview {
    searchView(text: .constant(""))
}
