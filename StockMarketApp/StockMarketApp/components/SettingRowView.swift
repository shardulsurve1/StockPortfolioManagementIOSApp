//
//  SettingRowView.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 11/25/23.
//

import SwiftUI

struct SettingRowView: View {
    let imageName : String
    let title: String
    let tintColor : Color
    
    var body: some View {
        HStack(spacing: 12){
            Image(systemName: imageName)
                .imageScale(.small)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    SettingRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
}
