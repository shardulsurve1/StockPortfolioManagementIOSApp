//
//  LoadingStateView.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/10/23.
//

import SwiftUI

struct LoadingStateView: View {
    var body: some View {
        HStack{
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
            Spacer()
        }
    }
}

#Preview {
    LoadingStateView()
}
