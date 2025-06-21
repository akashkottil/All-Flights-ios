import SwiftUI
import Alamofire
import Combine
import SafariServices

// MARK: - Main View
struct ExploreScreen: View {
    // MARK: - Properties
    @StateObject private var viewModel = ExploreViewModel()
    @State private var selectedTab = 0
    @State private var selectedFilterTab = 0
    @State private var selectedMonthTab = 0
    @State private var isRoundTrip: Bool = true
    
    // ADD: Observe shared search data
    @StateObject private var sharedSearchData = SharedSearchDataStore.shared
    
    // NEW: Add animation state tracking
    @State private var isInitialLoad = true
    @State private var showContentWithHeader = false
    
    @State private var showFilterModal = false
    
    @State private var hasAppliedInitialDirectFilter = false
    
    // ADD: State for native swipe gesture
    @State private var dragAmount = CGSize.zero
    
    private func applyInitialDirectFilterIfNeeded() {
        if viewModel.directFlightsOnlyFromHome && !hasAppliedInitialDirectFilter {
            print("🔧 Applying initial direct filter from HomeView toggle")
            selectedDetailedFlightFilter = .direct
            hasAppliedInitialDirectFilter = true
            applyDetailedFlightFilterOption(.direct)
        }
    }
    
    private func clearAllFiltersInExploreScreen() {
        print("🧹 Clearing all filters in ExploreScreen")
        
        // Reset detailed flight filter if we're in that view
        if viewModel.showingDetailedFlightList {
            selectedDetailedFlightFilter = .all
            
            // Reset the filter sheet state to defaults
            viewModel.filterSheetState = ExploreViewModel.FilterSheetState()
            
            // Create an empty filter request and apply it
            let emptyFilter = FlightFilterRequest()
            viewModel.applyPollFilters(filterRequest: emptyFilter)
        }
        
        print("✅ All filters cleared in ExploreScreen")
    }
    
    private func refreshCurrentScreen() {
        if viewModel.showingDetailedFlightList {
            // Refresh flight results using the current search parameters
            if !viewModel.selectedOriginCode.isEmpty && !viewModel.selectedDestinationCode.isEmpty {
                if viewModel.multiCityTrips.count > 1 {
                    // Multi-city search
                    viewModel.searchMultiCityFlightsWithPagination()
                } else {
                    // Regular search
                    viewModel.searchFlightsForDatesWithPagination(
                        origin: viewModel.selectedOriginCode,
                        destination: viewModel.selectedDestinationCode,
                        returnDate: viewModel.selectedReturnDatee,
                        departureDate: viewModel.selectedDepartureDatee,
                        isDirectSearch: viewModel.isDirectSearch
                    )
                }
            }
        } else if viewModel.showingCities {
            // Refresh cities using the selected country
            if let countryName = viewModel.selectedCountryName,
               let country = viewModel.destinations.first(where: { $0.location.name == countryName }) {
                viewModel.fetchCitiesFor(countryId: country.location.entityId, countryName: countryName)
            }
        } else {
            // Refresh main explore (countries)
            viewModel.fetchCountries()
        }
    }
    
    private var isInMainCountryView: Bool {
        return !viewModel.showingCities &&
               !viewModel.hasSearchedFlights &&
               !viewModel.showingDetailedFlightList &&
               !sharedSearchData.isInSearchMode &&
               viewModel.selectedCountryName == nil &&
               viewModel.selectedCity == nil
    }
    
    // NEW: Flag to track if we're in country navigation mode
    @State private var isCountryNavigationActive = false
    
    // Collapsible card states
    @State private var isCollapsed = false
    @State private var scrollOffset: CGFloat = 0
    @Namespace private var searchCardNamespace
    
    @State private var selectedDetailedFlightFilter: FlightFilterTabView.FilterOption = .all
    @State private var showingDetailedFlightFilterSheet = false
    
    private func applyDetailedFlightFilterOption(_ filter: FlightFilterTabView.FilterOption) {
        print("🔧 Applying detailed flight filter: \(filter.rawValue)")
        
        var filterRequest: FlightFilterRequest? = nil
        
        switch filter {
        case .all:
            // ✅ CRITICAL: For "All", create empty request but respect current filter sheet state
            filterRequest = FlightFilterRequest()
            // Don't override any existing filter sheet settings
            
        case .best:
            filterRequest = FlightFilterRequest()
            // Don't set sortBy for best - let API determine best results
            
        case .cheapest:
            filterRequest = FlightFilterRequest()
            filterRequest!.sortBy = "price"
            filterRequest!.sortOrder = "asc"
            
        case .fastest:
            filterRequest = FlightFilterRequest()
            filterRequest!.sortBy = "duration"
            filterRequest!.sortOrder = "asc"
            
        case .direct:
            filterRequest = FlightFilterRequest()
            filterRequest!.stopCountMax = 0
        }
        
        // Apply the filter if we have one
        if let request = filterRequest {
            viewModel.applyPollFilters(filterRequest: request)
        }
    }
    
    let filterOptions = ["Cheapest flights", "Direct Flights", "Suggested for you"]
    
    // NEW: Computed property for filtered destinations based on selected filter tab
    private var filteredDestinations: [ExploreDestination] {
        switch selectedFilterTab {
        case 0: // Cheapest flights (default)
            return viewModel.destinations.sorted { $0.price < $1.price }
        case 1: // Direct Flights
            return viewModel.destinations.filter { $0.is_direct }.sorted { $0.price < $1.price }
        case 2: // Suggested for you
            return viewModel.destinations.shuffled()
        default:
            return viewModel.destinations.sorted { $0.price < $1.price }
        }
    }
    
    // MODIFIED: Updated back navigation to handle "Anywhere" destination
    private func handleBackNavigation() {
        print("=== Back Navigation Debug ===")
        print("selectedFlightId: \(viewModel.selectedFlightId ?? "nil")")
        print("showingDetailedFlightList: \(viewModel.showingDetailedFlightList)")
        print("hasSearchedFlights: \(viewModel.hasSearchedFlights)")
        print("showingCities: \(viewModel.showingCities)")
        print("toLocation: \(viewModel.toLocation)")
        print("isDirectSearch: \(viewModel.isDirectSearch)")
        print("isInSearchMode: \(sharedSearchData.isInSearchMode)")
        
        // UPDATED: Special handling for search mode - return to home
        if sharedSearchData.isInSearchMode {
            print("Action: Search mode detected - returning to home")
            sharedSearchData.returnToHomeFromSearch()
            print("=== End Back Navigation Debug ===")
            return
        }
        
        // Special handling for direct searches from HomeView
        if viewModel.isDirectSearch {
            print("Action: Direct search detected - clearing form and returning to explore")
            
            if viewModel.selectedFlightId != nil {
                // If a flight is selected, deselect it first
                print("Action: Deselecting flight in direct search")
                viewModel.selectedFlightId = nil
            } else if viewModel.showingDetailedFlightList && viewModel.hasSearchedFlights {
                // CHANGED: If we have flight results and we're coming from search dates button
                // Just go back to flight results instead of clearing the form
                print("Action: Going back to flight results from search dates view")
                viewModel.showingDetailedFlightList = false
                // Don't clear search form here
            } else if viewModel.showingDetailedFlightList {
                // If on flight list from direct search (not from View these dates), go back and clear form
                print("Action: Going back from direct search flight list - clearing form")
                isCountryNavigationActive = false // Reset the flag
                viewModel.clearSearchFormAndReturnToExplore()
            } else {
                // Fallback - clear form
                print("Action: Fallback direct search back navigation - clearing form")
                isCountryNavigationActive = false // Reset the flag
                viewModel.clearSearchFormAndReturnToExplore()
            }
            print("=== End Back Navigation Debug ===")
            return
        }
        
        // Rest of the existing code remains unchanged
        // Special handling for "Anywhere" destination in explore flow
        if viewModel.toLocation == "Anywhere" {
            print("Action: Handling Anywhere destination - going back to countries")
            isCountryNavigationActive = false // Reset the flag
            sharedSearchData.resetAll() // Use the new resetAll method
            viewModel.resetToAnywhereDestination()
            return
        }
        
        // Regular explore flow navigation
        if viewModel.selectedFlightId != nil {
            // If a flight is selected, deselect it first (go back to flight list)
            print("Action: Deselecting flight (going back to flight list)")
            viewModel.selectedFlightId = nil
        } else if viewModel.showingDetailedFlightList {
            // If no flight is selected but we're on detailed flight list, go back to previous level
            print("Action: Going back from flight list to previous level")
            viewModel.goBackToFlightResults()
        } else if viewModel.hasSearchedFlights {
            // Go back from flight results to cities or countries
            if viewModel.toLocation == "Anywhere" {
                print("Action: Going back from flight results to countries (Anywhere)")
                isCountryNavigationActive = false // Reset the flag
                viewModel.goBackToCountries()
            } else {
                print("Action: Going back from flight results to cities")
                viewModel.goBackToCities()
            }
        } else if viewModel.showingCities {
            // Go back from cities to countries
            print("Action: Going back from cities to countries")
            isCountryNavigationActive = false // Reset the flag
            viewModel.goBackToCountries()
        }
        print("=== End Back Navigation Debug ===")
    }

    private func getCurrentMonthName() -> String {
        if !viewModel.isAnytimeMode && viewModel.selectedMonthIndex < viewModel.availableMonths.count {
            let selectedMonth = viewModel.availableMonths[viewModel.selectedMonthIndex]
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: selectedMonth)
        } else {
            // Fallback to current month
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: Date())
        }
    }
    
    // Add this computed property in ExploreScreen
    private var shouldShowBackButton: Bool {
        // Show back button only when NOT showing the main country list
        return viewModel.showingCities ||
               viewModel.hasSearchedFlights ||
               viewModel.showingDetailedFlightList ||
               sharedSearchData.isInSearchMode ||
               viewModel.selectedCountryName != nil
    }
    
    // MARK: - FIXED Sticky Header Components with Synchronized Animations
    private var stickyHeader: some View {
        VStack(spacing: 0) {
            // FIXED: Only show header content when showContentWithHeader is true for direct searches
            if showContentWithHeader || !viewModel.isDirectSearch {
                // Animated Title Section with proper sliding
                HStack {
                    // Main Explore Title + Filter Tabs (slides out left)
                    if !viewModel.hasSearchedFlights && !viewModel.showingDetailedFlightList {
                        VStack(spacing: 0) {
                            // Main Title
                            HStack {
                                Spacer()
                                Text(getExploreTitle())
                                    .font(.system(size: 24, weight: .bold))
                                    .padding(.horizontal)
                                    .padding(.top, 16)
                                Spacer()
                            }
                            .padding(.bottom, 16)
                            
                            // Filter Tabs
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(0..<filterOptions.count, id: \.self) { index in
                                        FilterTabButton(
                                            title: filterOptions[index],
                                            isSelected: selectedFilterTab == index
                                        ) {
                                            selectedFilterTab = index
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 5)
                        }
                        .frame(maxWidth: .infinity)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                    
                    // Flight Results Title + Month Selector (slides in from right)
                    if viewModel.hasSearchedFlights && !viewModel.showingDetailedFlightList {
                        VStack(spacing: 0) {
                            // Flight Results Title
                            HStack {
                                Spacer()
                                Text("Explore \(viewModel.toLocation)")
                                    .font(.system(size: 24, weight: .bold))
                                    .padding(.horizontal)
                                    .padding(.top, 16)
                                    .padding(.bottom, 8)
                                Spacer()
                            }
                            .padding(.bottom,10)
                            
                            // Conditional Content based on anytime mode
                            if !viewModel.isAnytimeMode {
                                // Month Selector
                                MonthSelectorView(
                                    months: viewModel.availableMonths,
                                    selectedIndex: viewModel.selectedMonthIndex,
                                    onSelect: { index in
                                        viewModel.selectMonth(at: index)
                                    }
                                )
                                .padding(.horizontal)
                                .padding(.bottom,5)
                            } else {
                                // Anytime Mode Message
                                Text("Best prices for the next 3 months")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                    .padding(.bottom, 5)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                    
                    // NEW: Detailed Flight List Title + Filter Tabs (slides in from right)
                    if viewModel.showingDetailedFlightList {
                        VStack(spacing: 0) {
                            // Detailed Flight List Title
                            if !viewModel.isDirectSearch{
                                HStack {
                                    Spacer()
                                    Text("Flights to \(viewModel.toLocation)")
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
                                    showingDetailedFlightFilterSheet = true
                                }
                                .padding(.leading, 20)
                                
                                FlightFilterTabView(
                                    selectedFilter: selectedDetailedFlightFilter,
                                    onSelectFilter: { filter in
                                        selectedDetailedFlightFilter = filter
                                        applyDetailedFlightFilterOption(filter)
                                    }
                                )
                            }
                            .padding(.trailing, 16)
                            .padding(.vertical, 8)
                            
                            // Flight count display
                            if viewModel.isLoadingDetailedFlights || viewModel.totalFlightCount > 0 {
                                HStack {
                                    FlightSearchStatusView(
                                        isLoading: viewModel.isLoadingDetailedFlights,
                                        flightCount: viewModel.totalFlightCount,
                                        destinationName: viewModel.toLocation
                                    )
                                }
                                .padding(.horizontal)
                                .padding(.top, 4)
                                .padding(.leading, 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .onAppear {
                               // ADD THIS LINE:
                               applyInitialDirectFilterIfNeeded()
                           }
                    }
                }
                .background(Color("scroll"))
                .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2), value: viewModel.hasSearchedFlights)
                .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2), value: viewModel.showingDetailedFlightList)
            }
        }
        .background(Color("scroll"))
        .zIndex(1) // Keep sticky header above scrollable content
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {
            
            VStack(spacing: 0) {
                // Custom navigation bar - Collapsible
                if isCollapsed {
                    CollapsedSearchCard(
                        viewModel: viewModel,
                        searchCardNamespace: searchCardNamespace,
                        onTap: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isCollapsed = false
                            }
                        },
                        handleBackNavigation: handleBackNavigation,
                        shouldShowBackButton: shouldShowBackButton
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    ExpandedSearchCard(
                        viewModel: viewModel,
                        selectedTab: $selectedTab,
                        isRoundTrip: $isRoundTrip,
                        searchCardNamespace: searchCardNamespace,
                        handleBackNavigation: handleBackNavigation,
                        shouldShowBackButton: shouldShowBackButton,
                        onDragCollapse: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                isCollapsed = true
                            }
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 1.05)))
                }
                
                // STICKY HEADER
                stickyHeader
                
                // SCROLLABLE CONTENT
                GeometryReader { geometry in
                    ScrollViewWithOffset(
                        offset: $scrollOffset,
                        content: {
                            VStack(alignment: .center, spacing: 16) {
                                // FIXED: Only show content when showContentWithHeader is true for direct searches
                                if showContentWithHeader || !viewModel.isDirectSearch {
                                    // Main content based on current state
                                    if viewModel.showingDetailedFlightList {
                                        // Detailed flight list - highest priority
                                        ModifiedDetailedFlightListView(
                                                viewModel: viewModel,
                                                isCollapsed: $isCollapsed,
                                                showFilterModal: $showFilterModal  // ADD: Pass the filter modal binding
                                            )
                                            .transition(.move(edge: .trailing))
                                            .zIndex(1)
                                            .edgesIgnoringSafeArea(.all)
                                            .background(Color(.systemBackground))
                                    }
                                    else if !viewModel.hasSearchedFlights {
                                        // Original explore view content (without title and filter tabs since they're sticky)
                                        exploreMainContent
                                    }
                                    else {
                                        // Flight search results view (without title and month selector since they're sticky)
                                        flightResultsContent
                                    }
                                }
                            }
                            .background(Color("scroll"))
                        }
                    )
                }
            }
            .networkModal {
                    // Refresh current screen when network comes back
                    refreshCurrentScreen()
                }
            .filterModal(
                isPresented: Binding(
                    get: { showFilterModal },
                    set: { showFilterModal = $0 }
                ),
                onClearFilters: {
                    clearAllFiltersInExploreScreen()
                }
            )
        }
        .background(Color("scroll"))
        .sheet(isPresented: $showingDetailedFlightFilterSheet) {
            FlightFilterSheet(viewModel: viewModel)
        }
        // ADD: Native-like edge swipe gesture for back navigation
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Only respond to swipes starting from the very left edge (like native iOS)
                    if value.startLocation.x < 20 && value.translation.width > 0 {
                        dragAmount = value.translation
                    }
                }
                .onEnded { value in
                    // Native-like behavior: shorter distance needed + velocity consideration
                    let shouldGoBack = value.startLocation.x < 20 &&
                                      (value.translation.width > 50 ||
                                       (value.translation.width > 30 && value.predictedEndTranslation.width > 80))
                    
                    if shouldGoBack {
                        // Add haptic feedback like native iOS
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        handleBackNavigation()
                    }
                    
                    // Smooth spring animation back to original position
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        dragAmount = .zero
                    }
                }
        )
        // ADD: More responsive visual feedback like native iOS
        .offset(x: dragAmount.width > 0 ? min(dragAmount.width * 0.4, 80) : 0)
        .animation(.interactiveSpring(response: 0.15, dampingFraction: 0.86), value: dragAmount)
        
        // Keep all your existing onAppear and onChange modifiers...
        .onAppear {
            print("🔍 ExploreScreen onAppear - checking states...")
            print("🔍 hasSearchedFlights: \(viewModel.hasSearchedFlights)")
            print("🔍 showingDetailedFlightList: \(viewModel.showingDetailedFlightList)")
            print("🔍 showingCities: \(viewModel.showingCities)")
            print("🔍 shouldNavigateToExploreCities: \(sharedSearchData.shouldNavigateToExploreCities)")
            print("🔍 shouldExecuteSearch: \(sharedSearchData.shouldExecuteSearch)")
            print("🔍 isInSearchMode: \(sharedSearchData.isInSearchMode)")
            print("🔍 isCountryNavigationActive: \(isCountryNavigationActive)")
            print("🔍 destinations count: \(viewModel.destinations.count)")
            print("🔍 sharedSearchData.selectedTab: \(sharedSearchData.selectedTab)")
            
            // UPDATED: Initialize selectedTab based on search mode
            if sharedSearchData.isInSearchMode {
                // If coming from direct search, use the original selectedTab but limit to available options
                if sharedSearchData.selectedTab == 2 {
                    // Multi-city search - keep as is
                    selectedTab = 2
                } else {
                    // Return or One-way - map appropriately
                    selectedTab = sharedSearchData.selectedTab
                }
                isRoundTrip = sharedSearchData.isRoundTrip
                print("🔍 Initialized from search mode: selectedTab=\(selectedTab), isRoundTrip=\(isRoundTrip)")
            } else {
                // Not in search mode - ensure we don't have multi-city selected
                if selectedTab >= 2 {
                    selectedTab = 0 // Reset to Return
                    isRoundTrip = true
                }
                print("🔍 Regular explore mode: selectedTab=\(selectedTab), isRoundTrip=\(isRoundTrip)")
            }
            
            // NEW: Check if we're in a clean explore state with countries already loaded
            let isInCleanExploreState = !viewModel.hasSearchedFlights &&
                                       !viewModel.showingDetailedFlightList &&
                                       !viewModel.showingCities &&
                                       viewModel.toLocation == "Anywhere" &&
                                       viewModel.selectedCountryName == nil &&
                                       viewModel.selectedCity == nil &&
                                       !viewModel.isDirectSearch
            
            let hasCountriesLoaded = !viewModel.destinations.isEmpty
            
            // If we're in clean state with countries loaded, don't do anything
            if isInCleanExploreState && hasCountriesLoaded &&
               !sharedSearchData.shouldExecuteSearch &&
               !sharedSearchData.shouldNavigateToExploreCities {
                print("🔍 Clean explore state with countries loaded - no action needed")
                showContentWithHeader = true // Ensure content is visible
                return
            }
            
            // Handle incoming search from HomeView
            if sharedSearchData.isInSearchMode && sharedSearchData.shouldExecuteSearch {
                print("🔍 Handling incoming search from HomeView")
                handleIncomingSearchFromHome()
                return
            }
            
            // Handle country-to-cities navigation from HomeView
            if sharedSearchData.shouldNavigateToExploreCities && !sharedSearchData.selectedCountryId.isEmpty {
                print("🔍 Handling country navigation from HomeView")
                handleIncomingCountryNavigation()
                return
            }
            
            // Check if user manually navigated to explore (not from search mode) and needs reset
            if !sharedSearchData.isInSearchMode &&
               !sharedSearchData.shouldExecuteSearch &&
               !sharedSearchData.shouldNavigateToExploreCities &&
               !isInCleanExploreState {
                
                print("🔄 Manual navigation to explore detected with dirty state - resetting view model")
                resetExploreViewModelToInitialState()
                
                // FIXED: Set loading state immediately and fetch countries without delay
                viewModel.isLoading = true
                showContentWithHeader = true // Show content immediately
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.fetchCountries()
                }
                return
            }
            
            // FIXED: Check if we need to fetch countries and do it immediately with loading state
            let shouldFetchCountries = viewModel.destinations.isEmpty &&
                                     isInCleanExploreState &&
                                     !sharedSearchData.shouldNavigateToExploreCities &&
                                     !sharedSearchData.shouldExecuteSearch &&
                                     !isCountryNavigationActive
            
            if shouldFetchCountries {
                print("🔍 Setting loading state and fetching countries immediately...")
                // FIXED: Set loading state immediately
                viewModel.isLoading = true
                showContentWithHeader = true // Show content immediately
                
                // FIXED: Fetch countries immediately (no delay)
                viewModel.fetchCountries()
            } else {
                print("🔍 Skipping country fetch - countries loaded or navigation state active")
                showContentWithHeader = true // Ensure content is visible
            }
            
            viewModel.setupAvailableMonths()
            updateTabVisibility()
        }
        .onChange(of: viewModel.showingCities) {
            updateTabVisibility()
        }
        .onChange(of: viewModel.hasSearchedFlights) {
            updateTabVisibility()
        }
        .onChange(of: viewModel.showingDetailedFlightList) { newValue in
            updateTabVisibility()
            
            if newValue && viewModel.isDirectSearch {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showContentWithHeader = true
                    }
                }
            }
            
            // ADD THESE LINES:
            if newValue {
                applyInitialDirectFilterIfNeeded()
            }
        }
        .onChange(of: viewModel.selectedCountryName) {
            updateTabVisibility()
        }
        .onChange(of: isInMainCountryView) {
            updateTabVisibility()
        }
        .onChange(of: scrollOffset) { newOffset in
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
        // ADD: Handle incoming search data from HomeView
        .onReceive(sharedSearchData.$shouldExecuteSearch) { shouldExecute in
            if shouldExecute && sharedSearchData.hasValidSearchData {
                handleIncomingSearchFromHome()
            }
        }
        // NEW: Handle country-to-cities navigation from HomeView
        .onReceive(sharedSearchData.$shouldNavigateToExploreCities) { shouldNavigate in
            if shouldNavigate && !sharedSearchData.selectedCountryId.isEmpty {
                print("🏙️ Received country navigation signal - processing immediately")
                // Process immediately to beat the onAppear delay
                handleIncomingCountryNavigation()
            }
        }
    }
    
    // MARK: - Content Views
    private var exploreMainContent: some View {
        VStack(spacing: 16) {
            // Destination cards (destinations/cities) - removed title and filter tabs
            if !viewModel.isLoading && viewModel.errorMessage == nil {
                VStack(spacing: 10) {
                    // UPDATED: Use filteredDestinations instead of viewModel.destinations
                    ForEach(filteredDestinations) { destination in
                        APIDestinationCard(
                            item: destination,
                            viewModel: viewModel,
                            onTap: {
                                if !viewModel.showingCities {
                                    viewModel.fetchCitiesFor(
                                        countryId: destination.location.entityId,
                                        countryName: destination.location.name
                                    )
                                } else {
                                    viewModel.selectCity(city: destination)
                                }
                            }
                        )
                        .padding(.horizontal,10)
                        .collapseSearchCardOnDrag(isCollapsed: $isCollapsed)
                    }
                }
                .padding(.top,20)
                .padding(.bottom, 16)
            }
            
            // Loading display
            if viewModel.isLoading {
                VStack(spacing: 10) {
                    ForEach(0..<5, id: \.self) { _ in
                        SkeletonDestinationCard()
                            .padding(.horizontal,10)
                            .collapseSearchCardOnDrag(isCollapsed: $isCollapsed)
                    }
                }
                .padding(.top,20)
                .padding(.bottom, 16)
            }
        }
    }
    
    private var flightResultsContent: some View {
        VStack(spacing: 14) {
            // Flight results content - removed title and month selector since they're sticky
            if viewModel.isLoadingFlights {
                ForEach(0..<3, id: \.self) { index in
                    SkeletonFlightResultCard()
                        .padding(.top, index == 0 ? 40 : 0)
                        .collapseSearchCardOnDrag(isCollapsed: $isCollapsed)
                }

            } else if viewModel.flightResults.isEmpty {
                // FIXED: Keep your auto-reload logic but prevent glitching with better state management
                VStack(spacing: 10) {
                    if viewModel.errorMessage != nil {
                        // Show error state
                        Image(systemName: "airplane.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Text("No flights found")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("Try adjusting your search or check back later")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    } else {
                        // Show loading state during auto-reload
                        ProgressView()
                            .scaleEffect(1.2)
                            .padding(.bottom, 8)
                        
                        Text("Loading flights...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Auto-reload trigger (keep your existing logic)
                    Text("")
                        .onAppear {
                            // Only trigger auto-reload if we don't have an explicit error
                            guard viewModel.errorMessage == nil else { return }
                            
                            // Automatically try to reload data if we have the necessary context
                            if let city = viewModel.selectedCity {
                                print("🔄 Auto-reloading flight data for city: \(city.location.name)")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    viewModel.fetchFlightDetails(destination: city.location.iata)
                                }
                            } else if !viewModel.toIataCode.isEmpty {
                                print("🔄 Auto-reloading flight data for destination: \(viewModel.toIataCode)")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    viewModel.fetchFlightDetails(destination: viewModel.toIataCode)
                                }
                            } else if viewModel.selectedMonthIndex < viewModel.availableMonths.count {
                                print("🔄 Auto-reloading flight data using current month selection")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    viewModel.selectMonth(at: viewModel.selectedMonthIndex)
                                }
                            }
                        }
                }
                .padding(.vertical, 40)
                .collapseSearchCardOnDrag(isCollapsed: $isCollapsed)
            } else {
                if !viewModel.isAnytimeMode && !viewModel.flightResults.isEmpty {
                    Text("Estimated cheapest price during \(getCurrentMonthName())")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .collapseSearchCardOnDrag(isCollapsed: $isCollapsed)
                }
                
                ForEach(viewModel.flightResults) { result in
                    FlightResultCard(
                        departureDate: viewModel.formatDate(result.outbound.departure ?? 0),
                        returnDate: result.inbound != nil && result.inbound?.departure != nil ?
                                   viewModel.formatDate(result.inbound!.departure!) : "No return",
                        origin: result.outbound.origin.iata,
                        destination: result.outbound.destination.iata,
                        price: "₹\(result.price)",
                        isOutDirect: result.outbound.direct,
                        isInDirect: result.inbound?.direct ?? false,
                        tripDuration: viewModel.calculateTripDuration(result),
                        viewModel: viewModel
                    )

                    .collapseSearchCardOnDrag(isCollapsed: $isCollapsed)
                }
            }
        }
    }
    
    // Keep all your existing private functions...
    private func updateTabVisibility() {
        // Don't interfere if we're already in search mode from HomeView
        guard !sharedSearchData.isInSearchMode else { return }
        
        DispatchQueue.main.async {
            let shouldShowTabs = isInMainCountryView
            
            // Update tab visibility based on current state
            if shouldShowTabs && sharedSearchData.isInExploreNavigation {
                // We're back to main country view - show tabs
                sharedSearchData.isInExploreNavigation = false
                print("📱 Showing tabs - back to main country view")
            } else if !shouldShowTabs && !sharedSearchData.isInExploreNavigation {
                // We're in cities/flights/details - hide tabs
                sharedSearchData.isInExploreNavigation = true
                print("📱 Hiding tabs - in cities/flights view")
            }
        }
    }
    
    // NEW: Handle country-to-cities navigation from HomeView
    private func handleIncomingCountryNavigation() {
        print("🏙️ ExploreScreen: Received country navigation from HomeView")
        print("🏙️ Country: \(sharedSearchData.selectedCountryName) (ID: \(sharedSearchData.selectedCountryId))")
        
        // IMMEDIATELY set the flag to prevent auto-fetching countries
        isCountryNavigationActive = true
        
        // Reset only the necessary search states (don't clear everything)
        viewModel.isDirectSearch = false
        viewModel.showingDetailedFlightList = false
        viewModel.hasSearchedFlights = false
        viewModel.flightResults = []
        viewModel.detailedFlightResults = []
        viewModel.selectedFlightId = nil
        
        // Set destination to "Anywhere" to show explore mode
        viewModel.toLocation = "Anywhere"
        viewModel.toIataCode = ""
        
        // IMMEDIATELY set up the view model to show cities for the specified country
        viewModel.showingCities = true
        viewModel.selectedCountryName = sharedSearchData.selectedCountryName
        
        // Store the navigation data locally before clearing it from shared store
        let countryId = sharedSearchData.selectedCountryId
        let countryName = sharedSearchData.selectedCountryName
        
        // Clear the shared search data immediately to prevent conflicts
        DispatchQueue.main.async {
            sharedSearchData.shouldNavigateToExploreCities = false
            sharedSearchData.selectedCountryId = ""
            sharedSearchData.selectedCountryName = ""
        }
        
        // Fetch cities for the selected country
        viewModel.fetchCitiesFor(countryId: countryId, countryName: countryName)
        
        // Reset the local flag after cities have loaded and settled
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isCountryNavigationActive = false
            print("🏙️ Country navigation flag reset")
        }
        
        print("🏙️ ExploreScreen: City navigation initiated successfully")
    }
    
    private func resetExploreViewModelToInitialState() {
        print("🔄 Resetting ExploreViewModel to initial state")
        viewModel.resetToInitialState(preserveCountries: true) // Preserve countries by default
        print("✅ ExploreViewModel reset completed")
    }
    
    // FIXED: Enhanced handleIncomingSearchFromHome with synchronized animations
    private func handleIncomingSearchFromHome() {
        print("🔥 ExploreScreen: Received search data from HomeView")
        print("🔥 Original selectedTab: \(sharedSearchData.selectedTab)")
        print("🔥 Direct flights only: \(sharedSearchData.directFlightsOnly)")
        
        // FIXED: Initialize showContentWithHeader to false for smooth animation
        showContentWithHeader = false
        
        // Transfer all search data to the view model
        viewModel.fromLocation = sharedSearchData.fromLocation
        viewModel.toLocation = sharedSearchData.toLocation
        viewModel.fromIataCode = sharedSearchData.fromIataCode
        viewModel.toIataCode = sharedSearchData.toIataCode
        viewModel.dates = sharedSearchData.selectedDates
        viewModel.isRoundTrip = sharedSearchData.isRoundTrip
        viewModel.adultsCount = sharedSearchData.adultsCount
        viewModel.childrenCount = sharedSearchData.childrenCount
        viewModel.childrenAges = sharedSearchData.childrenAges
        viewModel.selectedCabinClass = sharedSearchData.selectedCabinClass
        viewModel.multiCityTrips = sharedSearchData.multiCityTrips
        
        // UPDATED: Set selectedTab and isRoundTrip based on shared data
        selectedTab = sharedSearchData.selectedTab
        isRoundTrip = sharedSearchData.isRoundTrip
        
        // Set the selected origin and destination codes
        viewModel.selectedOriginCode = sharedSearchData.fromIataCode
        viewModel.selectedDestinationCode = sharedSearchData.toIataCode
        
        // Mark as direct search to show detailed flight list
        viewModel.isDirectSearch = true
        viewModel.showingDetailedFlightList = true
        
        // Store direct flights preference in view model for later use
        viewModel.directFlightsOnlyFromHome = sharedSearchData.directFlightsOnly
        
        // FIXED: Delay showing content until search is initiated to ensure smooth animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContentWithHeader = true
            }
        }
        
        // Handle multi-city vs regular search
        if sharedSearchData.selectedTab == 2 && !sharedSearchData.multiCityTrips.isEmpty {
            print("🔥 Executing multi-city search")
            // Multi-city search
            viewModel.searchMultiCityFlights()
        } else {
            print("🔥 Executing regular search (selectedTab: \(selectedTab))")
            // Regular search - format dates for API
            if !sharedSearchData.selectedDates.isEmpty {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                if sharedSearchData.selectedDates.count >= 2 {
                    let sortedDates = sharedSearchData.selectedDates.sorted()
                    viewModel.selectedDepartureDatee = formatter.string(from: sortedDates[0])
                    viewModel.selectedReturnDatee = formatter.string(from: sortedDates[1])
                } else if sharedSearchData.selectedDates.count == 1 {
                    viewModel.selectedDepartureDatee = formatter.string(from: sharedSearchData.selectedDates[0])
                    if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: sharedSearchData.selectedDates[0]) {
                        viewModel.selectedReturnDatee = formatter.string(from: nextDay)
                    }
                }
            }
            
            // Initiate the regular search
            viewModel.searchFlightsForDates(
                origin: sharedSearchData.fromIataCode,
                destination: sharedSearchData.toIataCode,
                returnDate: sharedSearchData.isRoundTrip ? viewModel.selectedReturnDatee : "",
                departureDate: viewModel.selectedDepartureDatee,
                isDirectSearch: true
            )
        }
        
        // Reset the shared search data
        sharedSearchData.resetSearch()
        
        print("🔥 ExploreScreen: Search initiated successfully")
    }
    
    // NEW: Helper method to get appropriate explore title
    private func getExploreTitle() -> String {
        if viewModel.toLocation == "Anywhere" {
            return "Explore everywhere"
        } else if viewModel.showingCities {
            return "Explore \(viewModel.selectedCountryName ?? "")"
        } else {
            return "Explore everywhere"
        }
    }
}

struct ExploreScreenPreview: PreviewProvider {
    static var previews: some View {
        ExploreScreen()
    }
}
