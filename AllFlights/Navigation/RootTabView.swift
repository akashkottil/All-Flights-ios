import SwiftUI

struct RootTabView: View {
    @StateObject private var sharedSearchData = SharedSearchDataStore.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView() // No need to pass binding
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
                
                // Reset the navigation trigger after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    sharedSearchData.shouldNavigateToExplore = false
                    
                    // Also reset country navigation flag if it was a country navigation
                    if sharedSearchData.shouldNavigateToExploreCities {
                        // Don't reset it immediately, let the explore screen handle it
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            if !sharedSearchData.shouldExecuteSearch {
                                // Only reset if no search is pending
                                sharedSearchData.shouldNavigateToExploreCities = false
                            }
                        }
                    }
                }
            }
        }
        // NEW: Listen for tab navigation requests
        .onReceive(sharedSearchData.$shouldNavigateToTab) { tabIndex in
            if let tabIndex = tabIndex {
                selectedTab = tabIndex
                
                // Reset the navigation trigger after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    sharedSearchData.shouldNavigateToTab = nil
                }
            }
        }
    }
}
