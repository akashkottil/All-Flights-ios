import SwiftUI
import Combine
import CoreLocation




// MARK: - Enhanced HomeView with Simplified Dynamic Cheap Flights
struct HomeView: View {
    @State private var isSearchExpanded = true
    @State private var navigateToAccount = false
    @Namespace private var animation
    @GestureState private var dragOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    
    // Shared view model for search functionality
    @StateObject private var searchViewModel = SharedFlightSearchViewModel()
    
    // Add CheapFlights view model
    @StateObject private var cheapFlightsViewModel = CheapFlightsViewModel()
    
    // UPDATED: Observe the recent search manager to track data changes
    @StateObject private var recentSearchManager = RecentSearchManager.shared
    
    // ADD: Track if we've shown the restored search to user
    @State private var hasShownRestoredSearch = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header + Search Inputs in a VStack with gradient background
                VStack(spacing: 0) {
                    headerView
                        .zIndex(1)

                    ZStack {
                        if isSearchExpanded {
                            EnhancedSearchInput(searchViewModel: searchViewModel)
                                .matchedGeometryEffect(id: "searchBox", in: animation)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .gesture(dragGesture)
                        } else {
                            HomeCollapsibleSearchInput(
                                isExpanded: $isSearchExpanded,
                                searchViewModel: searchViewModel
                            )
                            .matchedGeometryEffect(id: "searchBox", in: animation)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSearchExpanded)
                    .padding(.bottom, 20)
                }
                .background(
                    LinearGradient(colors: [Color("homeGrad"), .white], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea(edges: .top)
                )
                
                // IMPROVED: ScrollView with better offset tracking
                ScrollView {
                    VStack(spacing: 16) {
                        // Improved GeometryReader for scroll tracking
                        GeometryReader { geo in
                            Color.clear
                                .preference(
                                    key: ScrollOffsetPreferenceKeyy.self,
                                    value: geo.frame(in: .named("scrollView")).minY
                                )
                                .onPreferenceChange(ScrollOffsetPreferenceKeyy.self) { value in
                                    scrollOffset = value
                                    updateSearchExpandedState()
                                }
                        }
                        .frame(height: 0)

         

                        // UPDATED: Conditionally show recent search section
                        conditionalRecentSearchSection
                        
                        // Updated dynamic cheap flights section
                        dynamicCheapFlightsSection
                        
                        FeatureCards()
                        LoginNotifier()
                        ratingPrompt
                        BottomSignature()
                        
                        // Add extra padding at the bottom for better scrolling
                        Spacer().frame(height: 20)
                    }
                    .padding(.top, 16)
                }
                .coordinateSpace(name: "scrollView")
            }
            .navigationDestination(isPresented: $navigateToAccount) {
                AccountView()
            }
            .onAppear {
                // Fetch cheap flights data when home view appears
                cheapFlightsViewModel.fetchCheapFlights()
                
                // Show the restored search indicator briefly
                if searchViewModel.hasLastSearchData() && !hasShownRestoredSearch {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            hasShownRestoredSearch = true
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
    
    // NEW: Last search indicator

    
    // IMPROVED: Function to update search expanded state based on scroll
    private func updateSearchExpandedState() {
        let threshold: CGFloat = -20
        
        // Enhanced spring animation with haptic feedback
        if scrollOffset < threshold && isSearchExpanded {
            // Collapsing - subtle haptic feedback
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
            
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                isSearchExpanded = false
            }
        } else if scrollOffset > 0 && !isSearchExpanded {
            // Expanding
            withAnimation(.interpolatingSpring(stiffness: 280, damping: 25)) {
                isSearchExpanded = true
            }
        }
    }

    // MARK: - UPDATED: Conditional Recent Search Section
    @ViewBuilder
    private var conditionalRecentSearchSection: some View {
        if !recentSearchManager.recentSearches.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Recent Search")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                    Spacer()
                    Button(action: {
                        // UPDATED: Animate the section away when clearing
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            recentSearchManager.clearAllRecentSearches()
                        }
                    }) {
                        Text("Clear All")
                            .foregroundColor(Color("ThridColor"))
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal)

                RecentSearch(searchViewModel: searchViewModel)
            }
            .transition(.asymmetric(
                insertion: .move(edge: .top)
                    .combined(with: .opacity)
                    .combined(with: .scale(scale: 0.95)),
                removal: .move(edge: .top)
                    .combined(with: .opacity)
                    .combined(with: .scale(scale: 0.95))
            ))
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: recentSearchManager.recentSearches.isEmpty)
        }
    }

    // MARK: - Dynamic Cheap Flights Section
    var dynamicCheapFlightsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Text("Cheapest Fares From ")
                    .fontWeight(.medium)
                + Text(cheapFlightsViewModel.fromLocationName)
                    .foregroundColor(.blue)

                Image(systemName: "chevron.down")
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)

            DynamicCheapFlights(viewModel: cheapFlightsViewModel)
        }
    }

    // MARK: - Drag Gesture for collapsing SearchInput
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                if value.translation.height < -20 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        isSearchExpanded = false
                    }
                }
            }
    }


    // MARK: - Header View (Updated section from HomeView)
    var headerView: some View {
        HStack {
            Image("logoHome")
                .resizable()
                .frame(width: 28, height: 28)
                .cornerRadius(6)
                .padding(.trailing, 4)

            Text("All Flights")
                .font(.system(size: 22))
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Spacer()

            Button(action: {
                // Set account navigation state before navigating
                SharedSearchDataStore.shared.enterAccountNavigation()
                navigateToAccount = true
            }) {
                Image("homeProfile")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal, 25)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Rating Prompt (original style)
    var ratingPrompt: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("gradientBlueLeft"), Color("gradientBlueRight")]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .cornerRadius(12)
            
            HStack {
                Image("starImg")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("How do you feel?")
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("Rate us On Appstore")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("Rate Us")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color("buttonBlue"))
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }
}


// MARK: - Preview
#Preview {
    HomeView()
}
