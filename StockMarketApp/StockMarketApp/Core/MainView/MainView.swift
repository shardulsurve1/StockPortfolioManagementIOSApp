//
//  MainView.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 12/4/23.
//

import SwiftUI

enum Tab : String , CaseIterable{
    case book
    case bookmark
    case bag
    case person
}

struct MainView: View {
    @Binding var selectedTab : Tab
    private var fillImage: String{
        selectedTab.rawValue + ".fill"
    }
    
    private var tabColor : Color{
        switch selectedTab {
            
        case .book:
            return .blue
        case .bookmark:
            return .green
        case .bag:
            return .indigo
        case .person:
            return .orange
        }
    }
    var body: some View {
        VStack{
            Spacer()
            HStack{
                ForEach(Tab.allCases,id: \.rawValue){ tab in
                   Spacer()
                    Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                        .scaleEffect(selectedTab == tab ? 1.25: 1.0)
                        .foregroundColor(selectedTab == tab ? tabColor : .gray)
                        .font(.system(size: 22))
                        .onTapGesture{
                            withAnimation(.easeIn(duration: 0.1)){
                                selectedTab = tab
                            }
                        }
                    Spacer()
                }
            }
            .frame(width: nil, height: 60)
            .background(.thinMaterial)
            .cornerRadius(10)
            .padding()
            
        }
    }
}

#Preview {
    MainView(selectedTab: .constant(.person))
}
