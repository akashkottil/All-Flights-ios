import SwiftUI
import Combine
import CoreLocation

// MARK: - Enhanced HomeView with Complete ExploreScreen Transformation
struct HomeView: View {
    @State private var isSearchExpanded = true
    @State private var navigateToAccount = false
    @Namespace private var animation
    @GestureState private var dragOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    
    // NEW: State for complete transformation to ExploreScreen
    @State private var isShowingExploreScreen = false
    @State private var homeContentOpacity: Double = 1.0
    @State private var exploreContentOpacity: Double = 0.0
    @State private var homeContentOffset: CGFloat = 0
    @State private var exploreContentOffset: CGFloat = 0
    
    // NEW: Enhanced animation states for skeletons and search card
    @State private var skeletonsVisible = false
    @State private var searchCardOvershoot = false
    
    // NEW: Collapsible card states for ExploreScreen
    @State private var isCollapsed = false
    @State private var exploreScrollOffset: CGFloat = 0
    
    // Shared view model for search functionality
    @StateObject private var searchViewModel = SharedFlightSearchViewModel()
    
    // Add CheapFlights view model
    @StateObject private var cheapFlightsViewModel = CheapFlightsViewModel()
    
    // UPDATED: Observe the recent search manager to track data changes
    @StateObject private var recentSearchManager = RecentSearchManager.shared
    
    // ADD: Track if we've shown the restored search to user
    @State private var hasShownRestoredSearch = false
    
    // NEW: ExploreViewModel for transformed results
    @StateObject private var exploreViewModel = ExploreViewModel()
    
    // NEW: State for explore screen components
    @State private var selectedTab = 0
    @State private var selectedFilterTab = 0
    @State private var selectedMonthTab = 0
    @State private var isRoundTrip: Bool = true
    @State private var showFilterModal = false
    
    private func refreshHomeData() {
        // Refresh cheap flights data
        cheapFlightsViewModel.fetchCheapFlights()
    }
    
    // NEW: Enhanced complete transformation to ExploreScreen with skeleton animations
    private func transformToExploreScreen() {
        print("🔄 Starting enhanced transformation to ExploreScreen")
        
        // Reset animation states
        skeletonsVisible = false
        searchCardOvershoot = false
        
        // Prevent interaction during transformation
        isShowingExploreScreen = true
        
        // Phase 1: Fade out home content and prepare explore content
        withAnimation(.easeInOut(duration: 0.4)) {
            homeContentOpacity = 0.0
            homeContentOffset = -50
        }
        
        // Phase 2: Transfer search data and initialize explore
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            transferSearchDataToExplore()
        }
        
        // Phase 3: Slide in explore content with search card (works exactly as before)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                exploreContentOpacity = 1.0
                exploreContentOffset = 0
            }
        }
        
        // Phase 4: After search card is settled, add overshoot towards top (earlier and more movement)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
                searchCardOvershoot = true
            }
        }
        
        // Phase 5: Skeleton cards slide in from bottom with staggered overshoot
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                skeletonsVisible = true
            }
        }
    }
    
    // NEW: Transform back to HomeView
    private func transformBackToHome() {
        print("🏠 Transforming back to HomeView")
        
        // Phase 1: Hide skeletons first
        withAnimation(.easeOut(duration: 0.3)) {
            skeletonsVisible = false
        }
        
        // Phase 2: Hide explore content
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.4)) {
                exploreContentOpacity = 0.0
                exploreContentOffset = 50
            }
        }
        
        // Phase 3: Show home content
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                homeContentOpacity = 1.0
                homeContentOffset = 0
                isShowingExploreScreen = false
            }
        }
        
        // Reset explore view model and animation states
        exploreViewModel.resetToInitialState()
        isCollapsed = false
        exploreScrollOffset = 0
        searchCardOvershoot = false
        skeletonsVisible = false
    }
    
    // NEW: Transfer search data to explore view model
    private func transferSearchDataToExplore() {
        // Transfer all search data to the explore view model
        exploreViewModel.fromLocation = searchViewModel.fromLocation
        exploreViewModel.toLocation = searchViewModel.toLocation
        exploreViewModel.fromIataCode = searchViewModel.fromIataCode
        exploreViewModel.toIataCode = searchViewModel.toIataCode
        exploreViewModel.dates = searchViewModel.selectedDates
        exploreViewModel.isRoundTrip = searchViewModel.isRoundTrip
        exploreViewModel.adultsCount = searchViewModel.adultsCount
        exploreViewModel.childrenCount = searchViewModel.childrenCount
        exploreViewModel.childrenAges = searchViewModel.childrenAges
        exploreViewModel.selectedCabinClass = searchViewModel.selectedCabinClass
        exploreViewModel.multiCityTrips = searchViewModel.multiCityTrips
        
        // Set the selected origin and destination codes
        exploreViewModel.selectedOriginCode = searchViewModel.fromIataCode
        exploreViewModel.selectedDestinationCode = searchViewModel.toIataCode
        
        // Mark as direct search to show detailed flight list
        exploreViewModel.isDirectSearch = true
        exploreViewModel.showingDetailedFlightList = true
        
        // Store direct flights preference
        exploreViewModel.directFlightsOnlyFromHome = searchViewModel.directFlightsOnly
        
        // Sync tab states
        selectedTab = searchViewModel.selectedTab
        isRoundTrip = searchViewModel.isRoundTrip
        
        // Handle multi-city vs regular search
        if searchViewModel.selectedTab == 2 && !searchViewModel.multiCityTrips.isEmpty {
            // Multi-city search
            exploreViewModel.searchMultiCityFlights()
        } else {
            // Regular search - format dates for API
            if !searchViewModel.selectedDates.isEmpty {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                if searchViewModel.selectedDates.count >= 2 {
                    let sortedDates = searchViewModel.selectedDates.sorted()
                    exploreViewModel.selectedDepartureDatee = formatter.string(from: sortedDates[0])
                    exploreViewModel.selectedReturnDatee = formatter.string(from: sortedDates[1])
                } else if searchViewModel.selectedDates.count == 1 {
                    exploreViewModel.selectedDepartureDatee = formatter.string(from: searchViewModel.selectedDates[0])
                    if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: searchViewModel.selectedDates[0]) {
                        exploreViewModel.selectedReturnDatee = formatter.string(from: nextDay)
                    }
                }
            }
            
            // Initiate the regular search
            exploreViewModel.searchFlightsForDates(
                origin: searchViewModel.fromIataCode,
                destination: searchViewModel.toIataCode,
                returnDate: searchViewModel.isRoundTrip ? exploreViewModel.selectedReturnDatee : "",
                departureDate: exploreViewModel.selectedDepartureDatee,
                isDirectSearch: true
            )
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Original Home Content
                VStack(spacing: 0) {
                    // Header + Search Inputs in a VStack with gradient background
                    VStack(spacing: 0) {
                        headerView
                            .zIndex(1)

                        ZStack {
                            if isSearchExpanded {
                                EnhancedSearchInput(
                                    searchViewModel: searchViewModel,
                                    onSearchTap: {
                                        transformToExploreScreen()
                                    }
                                )
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
                .opacity(homeContentOpacity)
                .offset(y: homeContentOffset)
                
                // MARK: - Complete ExploreScreen Overlay with Enhanced Animations
                if isShowingExploreScreen {
                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            // Custom navigation bar - Collapsible with overshoot animation
                            if isCollapsed {
                                CollapsedSearchCard(
                                    viewModel: exploreViewModel,
                                    searchCardNamespace: animation,
                                    onTap: {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            isCollapsed = false
                                        }
                                    },
                                    handleBackNavigation: transformBackToHome,
                                    shouldShowBackButton: true
                                )
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            } else {
                                ExpandedSearchCard(
                                    viewModel: exploreViewModel,
                                    selectedTab: $selectedTab,
                                    isRoundTrip: $isRoundTrip,
                                    searchCardNamespace: animation,
                                    handleBackNavigation: transformBackToHome,
                                    shouldShowBackButton: true,
                                    onDragCollapse: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                            isCollapsed = true
                                        }
                                    }
                                )
                                .transition(.opacity.combined(with: .scale(scale: 1.05)))
                                // Enhanced overshoot animation towards the top after search card is settled
                                .offset(y: searchCardOvershoot ? -15 : 0)
                                .animation(.spring(response: 0.7, dampingFraction: 0.65), value: searchCardOvershoot)
                            }
                            
                            // STICKY HEADER
                            stickyHeader
                            
                            // SCROLLABLE CONTENT with Enhanced Skeleton Animations
                            GeometryReader { geometry in
                                ScrollViewWithOffset(
                                    offset: $exploreScrollOffset,
                                    content: {
                                        VStack(alignment: .center, spacing: 16) {
                                            // Main content based on current state
                                            if exploreViewModel.showingDetailedFlightList {
                                                // Detailed flight list - highest priority
                                                ModifiedDetailedFlightListView(
                                                    viewModel: exploreViewModel,
                                                    isCollapsed: $isCollapsed,
                                                    showFilterModal: $showFilterModal
                                                )
                                                .transition(.move(edge: .trailing))
                                                .zIndex(1)
                                                .edgesIgnoringSafeArea(.all)
                                                .background(Color(.systemBackground))
                                            } else {
                                                // Enhanced skeleton cards with slide-in animation
                                                VStack(spacing: 16) {
                                                    ForEach(0..<5, id: \.self) { index in
                                                        EnhancedDetailedFlightCardSkeleton()
                                                            .padding(.horizontal)
                                                            // Enhanced slide-in animation from bottom
                                                            .offset(y: skeletonsVisible ? 0 : 300)
                                                            .opacity(skeletonsVisible ? 1 : 0)
                                                            .scaleEffect(skeletonsVisible ? 1.0 : 0.8)
                                                            .animation(
                                                                .spring(
                                                                    response: 0.8,
                                                                    dampingFraction: 0.6,
                                                                    blendDuration: 0.1
                                                                )
                                                                .delay(Double(index) * 0.1),
                                                                value: skeletonsVisible
                                                            )
                                                    }
                                                }
                                                .padding(.top, 20)
                                            }
                                        }
                                        .background(Color("scroll"))
                                    }
                                )
                            }
                        }
                        .networkModal {
                            // Refresh functionality if needed
                        }
                        .filterModal(
                            isPresented: Binding(
                                get: { showFilterModal },
                                set: { showFilterModal = $0 }
                            ),
                            onClearFilters: {
                                // Clear filters logic
                            }
                        )
                    }
                    .background(Color("scroll"))
                    .opacity(exploreContentOpacity)
                    .offset(y: exploreContentOffset)
                    .onChange(of: exploreScrollOffset) { newOffset in
                        // Collapse when scrolled down more than 50 points and not already collapsed
                        let shouldCollapse = newOffset > 50
                        
                        if shouldCollapse && !isCollapsed {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isCollapsed = true
                            }
                        } else if !shouldCollapse && isCollapsed && newOffset < 20 {
                            // Expand when scrolled back up
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isCollapsed = false
                            }
                        }
                    }
                }
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
        .networkModal {
            refreshHomeData()
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Sticky Header
    private var stickyHeader: some View {
        VStack(spacing: 0) {
            // Only show header content when appropriate
            if exploreContentOpacity > 0.5 {
                // Animated Title Section with proper sliding
                HStack {
                    // Flight Results Title + Filter Tabs (slides in from right)
                    if exploreViewModel.showingDetailedFlightList {
                        VStack(spacing: 0) {
                            // Detailed Flight List Title
                            if !exploreViewModel.isDirectSearch {
                                HStack {
                                    Spacer()
                                    Text("Flights to \(exploreViewModel.toLocation)")
                                        .font(.system(size: 24, weight: .bold))
                                        .padding(.horizontal)
                                        .padding(.top, 16)
                                        .padding(.bottom, 8)
                                    Spacer()
                                }
                            }
                            
                            // Filter tabs section for detailed flight list
                            HStack {
                                FilterButton {
                                    showFilterModal = true
                                }
                                .padding(.leading, 20)
                                
                                FlightFilterTabView(
                                    selectedFilter: .all,
                                    onSelectFilter: { filter in
                                        // Handle filter selection
                                    }
                                )
                            }
                            .padding(.trailing, 16)
                            .padding(.vertical, 8)
                            
                            // Flight count display
                            if exploreViewModel.isLoadingDetailedFlights || exploreViewModel.totalFlightCount > 0 {
                                HStack {
                                    FlightSearchStatusView(
                                        isLoading: exploreViewModel.isLoadingDetailedFlights,
                                        flightCount: exploreViewModel.totalFlightCount,
                                        destinationName: exploreViewModel.toLocation
                                    )
                                }
                                .padding(.horizontal)
                                .padding(.top, 4)
                                .padding(.leading, 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .background(Color("scroll"))
                .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2), value: exploreViewModel.showingDetailedFlightList)
            }
        }
        .background(Color("scroll"))
        .zIndex(1)
    }
    
    // IMPROVED: Function to update search expanded state based on scroll
    private func updateSearchExpandedState() {
        // Don't update if showing explore screen
        guard !isShowingExploreScreen else { return }
        
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

    // MARK: - Header View
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
    
    // MARK: - Rating Prompt
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
