import SwiftUI

struct RootTabView: View {
    @StateObject private var sharedSearchData = SharedSearchDataStore.shared
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
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
            .opacity(sharedSearchData.isInSearchMode ? 0 : 1)
            
            // Overlay the explore screen when in search mode
            if sharedSearchData.isInSearchMode {
                ExploreScreen()
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: sharedSearchData.isInSearchMode)
        .onReceive(sharedSearchData.$shouldNavigateToExplore) { shouldNavigate in
            if shouldNavigate {
                if !sharedSearchData.isInSearchMode {
                    // Only switch tabs if not in search mode
                    selectedTab = 2
                }
                
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
        .onReceive(sharedSearchData.$shouldNavigateToTab) { tabIndex in
            if let tabIndex = tabIndex {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = tabIndex
                }
                
                // Reset the navigation trigger after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    sharedSearchData.shouldNavigateToTab = nil
                }
            }
        }
    }
}
