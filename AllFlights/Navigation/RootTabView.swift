import SwiftUI

struct RootTabView: View {
    @StateObject private var sharedSearchData = SharedSearchDataStore.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            AlertsView()
                .tabItem {
                    Label("Alert", systemImage: "bell.badge.fill")
                }
                .tag(1)

            ExploreScreen()
                .tabItem {
                    Label("Explore", systemImage: "globe")
                }
                .tag(2)

            FlightTrackerScreen()
                .tabItem {
                    Label("Track Flight", systemImage: "paperplane.circle.fill")
                }
                .tag(3)
        }
        .onReceive(sharedSearchData.$shouldNavigateToExplore) { shouldNavigate in
            if shouldNavigate {
                // Switch to explore tab
                selectedTab = 2
                
                // Reset the navigation trigger
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    sharedSearchData.shouldNavigateToExplore = false
                }
            }
        }
    }
}
