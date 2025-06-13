import SwiftUICore
import SwiftUI

struct RootTabView: View {
    @StateObject private var sharedSearchData = SharedSearchDataStore.shared
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            ZStack {
                Group {
                    switch selectedTab {
                    case 0:
                        HomeView()
                    case 1:
                        AlertsView()
                    case 2:
                        ExploreScreen()
                    case 3:
                        FlightTrackerScreen()
                    default:
                        HomeView()
                    }
                }
                .opacity(sharedSearchData.isInSearchMode ? 0 : 1)
                
                // Overlay for search mode
                if sharedSearchData.isInSearchMode {
                    ExploreScreen()
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                }
            }
            
            // Custom Tab Bar - hide when in explore navigation, search mode, OR account navigation
            if !sharedSearchData.isInSearchMode &&
               !sharedSearchData.isInExploreNavigation &&
               !sharedSearchData.isInAccountNavigation {
                CustomTabBar(selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: sharedSearchData.isInSearchMode)
        .animation(.easeInOut(duration: 0.5), value: sharedSearchData.isInExploreNavigation)
        .animation(.easeInOut(duration: 0.5), value: sharedSearchData.isInAccountNavigation) // ADD: Account navigation animation
        .onReceive(sharedSearchData.$shouldNavigateToExplore) { shouldNavigate in
            if shouldNavigate {
                if !sharedSearchData.isInSearchMode {
                    selectedTab = 2
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    sharedSearchData.shouldNavigateToExplore = false
                    
                    if sharedSearchData.shouldNavigateToExploreCities {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            if !sharedSearchData.shouldExecuteSearch {
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    sharedSearchData.shouldNavigateToTab = nil
                }
            }
        }
    }
}

// Custom Tab Bar Component
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    private let tabItems = [
        ("Home", "home", 0, "homeblue"),
        ("Alert", "alert", 1, "alertblue"),
        ("Explore", "explore", 2, "exploreblue"),
        ("Track Flight", "flighttracker", 3, "flighttrackerblue")
    ]
    
    var body: some View {
        HStack {
            ForEach(tabItems, id: \.2) { item in
                Button(action: {
                    selectedTab = item.2
                }) {
                    VStack(spacing: 4) {
                        Image(selectedTab == item.2 ? "\(item.3)" : "\(item.1)")
                            .font(.system(size: 20))
                        Text(item.0)
                            .font(.caption)
                            .fontWeight(selectedTab == item.2 ? .bold : .regular)
                    }
                    .foregroundColor(selectedTab == item.2 ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 2)
        .padding(.top, 10)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }
}
