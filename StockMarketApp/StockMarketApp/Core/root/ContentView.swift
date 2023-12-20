import SwiftUI
import FirebaseCore

struct ContentView: View {
    @State private var selectedTab: Tab = .book
    @EnvironmentObject var viewModel: AuthViewModel

    init() {
        UITabBar.appearance().isHidden = true
    }

    private var tabView: some View {
        switch selectedTab {
        case .book:
            return AnyView(stocksView())
        case .bookmark:
            return AnyView(watchlistView())
        case .bag:
            return AnyView(portfolioView())
        case .person:
            return AnyView(ProfileView())
        }
    }


    var body: some View {
        Group {
            if viewModel.userSession != nil {
                ZStack {
                    VStack {
                        TabView(selection: $selectedTab) {
                            ForEach(Tab.allCases, id: \.rawValue) { tab in
                                tabView.tag(tab)
                            }
                        }
                    }
                    VStack {
                        MainView(selectedTab: $selectedTab)
                    }
                }
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AuthViewModel())  // Assuming AuthViewModel is an ObservableObject
    }
}
