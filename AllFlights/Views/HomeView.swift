import SwiftUI
import Combine

// MARK: - Updated SharedFlightSearchViewModel for HomeView
class SharedFlightSearchViewModel: ObservableObject {
    @Published var fromLocation = "Departure?"
    @Published var toLocation = "Destination?"
    @Published var fromIataCode: String = "" // Default to Delhi
    @Published var toIataCode: String = ""
    
    @Published var selectedDates: [Date] = []
    @Published var isRoundTrip: Bool = true
    @Published var selectedTab = 0 // 0: Return, 1: One way, 2: Multi city
    
    @Published var adultsCount = 1
    @Published var childrenCount = 0
    @Published var childrenAges: [Int?] = []
    @Published var selectedCabinClass = "Economy"
    
    @Published var multiCityTrips: [MultiCityTrip] = []
    
    // ADD: Direct flights toggle state
    @Published var directFlightsOnly = false
    
    func executeMultiCitySearch() {
        // Validate all trips have required data
        let isValid = multiCityTrips.allSatisfy { trip in
            !trip.fromIataCode.isEmpty && !trip.toIataCode.isEmpty
        }
        
        guard isValid else {
            print("❌ Multi-city validation failed")
            return
        }
        
        // Save to recent searches before executing the search
        saveToRecentSearches()
        
        // UPDATED: Pass direct flights preference
        SharedSearchDataStore.shared.executeSearchFromHome(
            fromLocation: fromLocation,
            toLocation: toLocation,
            fromIataCode: fromIataCode,
            toIataCode: toIataCode,
            selectedDates: selectedDates,
            isRoundTrip: isRoundTrip,
            selectedTab: selectedTab,
            adultsCount: adultsCount,
            childrenCount: childrenCount,
            childrenAges: childrenAges,
            selectedCabinClass: selectedCabinClass,
            multiCityTrips: multiCityTrips,
            directFlightsOnly: directFlightsOnly
        )
        
        print("✅ Multi-city search executed with \(multiCityTrips.count) trips")
    }
    
    // Use the shared recent search manager
    var recentSearchManager: RecentSearchManager {
        return RecentSearchManager.shared
    }
   
    // Initialize multi-city trips
    // Initialize multi-city trips - UPDATED: Start with empty trips instead of pre-populated data
    func initializeMultiCityTrips() {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        
        multiCityTrips = [
            MultiCityTrip(fromLocation: "Departure?", fromIataCode: "",
                         toLocation: "Destination?", toIataCode: "", date: tomorrow),
            MultiCityTrip(fromLocation: "Departure?", fromIataCode: "",
                         toLocation: "Destination?", toIataCode: "", date: dayAfterTomorrow)
        ]
    }

    // Update children ages array when count changes
    func updateChildrenAgesArray(for newCount: Int) {
        if newCount > childrenAges.count {
            childrenAges.append(contentsOf: Array(repeating: nil, count: newCount - childrenAges.count))
        } else if newCount < childrenAges.count {
            childrenAges = Array(childrenAges.prefix(newCount))
        }
    }
    
    // UPDATED: executeSearch to use shared data store
    func executeSearch() {
        // Save to recent searches before executing the search
        saveToRecentSearches()
        
        // UPDATED: Pass direct flights preference
        SharedSearchDataStore.shared.executeSearchFromHome(
            fromLocation: fromLocation,
            toLocation: toLocation,
            fromIataCode: fromIataCode,
            toIataCode: toIataCode,
            selectedDates: selectedDates,
            isRoundTrip: isRoundTrip,
            selectedTab: selectedTab,
            adultsCount: adultsCount,
            childrenCount: childrenCount,
            childrenAges: childrenAges,
            selectedCabinClass: selectedCabinClass,
            multiCityTrips: multiCityTrips,
            directFlightsOnly: directFlightsOnly
        )
    }
    
    // Save current search to recent searches
    private func saveToRecentSearches() {
        recentSearchManager.addRecentSearch(
            fromLocation: fromLocation,
            toLocation: toLocation,
            fromIataCode: fromIataCode,
            toIataCode: toIataCode,
            adultsCount: adultsCount,
            childrenCount: childrenCount,
            cabinClass: selectedCabinClass
        )
    }
    
    // Keep the old method for backward compatibility (but it now does the same thing)
    func executeSearchWithHistory() {
        executeSearch()
    }
}


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
            }
        }
        .scrollIndicators(.hidden)
    }
    
    // IMPROVED: Function to update search expanded state based on scroll
    private func updateSearchExpandedState() {
        let threshold: CGFloat = -20  // Adjust this value to make it more or less sensitive
        
        // Only collapse when scrolling down, expand when at the top
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            if scrollOffset < threshold && isSearchExpanded {
                isSearchExpanded = false
            } else if scrollOffset > 0 && !isSearchExpanded {
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
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Spacer()

            Image("homeProfile")
                .resizable()
                .frame(width: 36, height: 36)
                .cornerRadius(6)
                .padding(.trailing, 4)
                .onTapGesture {
                    navigateToAccount = true
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

// MARK: - Enhanced Search Input Component (exact UI match)
struct EnhancedSearchInput: View {
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    @State private var showingFromLocationSheet = false
    @State private var showingToLocationSheet = false
    @State private var showingCalendar = false
    @State private var showingPassengersSheet = false

    @State private var editingTripIndex = 0
    @State private var editingFromOrTo: LocationType = .from
    
    @State private var swapRotationDegrees: Double = 0
    
    @State private var showErrorMessage = false
    
    @State private var showDirectFlightsToggle = true
    
    // Animation namespace for matched geometry effects
       @Namespace private var tripAnimation
    
    var canAddTrip: Bool {
        // Check if the last trip's "To" field is filled (destination selected)
        if let lastTrip = searchViewModel.multiCityTrips.last {
            return !lastTrip.toLocation.isEmpty &&
                   !lastTrip.toIataCode.isEmpty &&
                   lastTrip.toLocation != "Destination?"
        }
        return false
    }
    
    private func getFromLocationDisplayText() -> String {
        if searchViewModel.fromIataCode.isEmpty {
            return ""
        }
        return searchViewModel.fromIataCode
    }

    private func getFromLocationTextColor() -> Color {
        if searchViewModel.fromIataCode.isEmpty {
            return .gray
        }
        return .primary
    }

    private func getFromLocationNameTextColor() -> Color {
        if searchViewModel.fromLocation.isEmpty || searchViewModel.fromLocation == "Departure?" {
            return .gray
        }
        return .primary
    }

    private func getToLocationDisplayText() -> String {
        if searchViewModel.toIataCode.isEmpty {
            return ""
        }
        return searchViewModel.toIataCode
    }

    private func getToLocationTextColor() -> Color {
        if searchViewModel.toIataCode.isEmpty {
            return .gray
        }
        return .primary
    }

    private func getToLocationNameTextColor() -> Color {
        if searchViewModel.toLocation.isEmpty || searchViewModel.toLocation == "Destination?" {
            return .gray
        }
        return .primary
    }

    private func getDateDisplayText() -> String {
        if searchViewModel.selectedDates.isEmpty {
            // Set a default departure date (e.g., today's date)
            let formatter = DateFormatter()
            formatter.dateFormat = "E, d MMM"
            
            if searchViewModel.isRoundTrip {
                // For round trip, return two default dates (departure and return)
                let returnDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date() // Default return date (7 days later)
                return "\(formatter.string(from: Date())) - \(formatter.string(from: returnDate))"
            } else {
                // For one-way, return only the departure date
                return formatter.string(from: Date()) // Default to today's date
            }
        } else if searchViewModel.selectedDates.count == 1 {
            // One-way trip: Show the selected departure date
            return formatDateForDisplay(searchViewModel.selectedDates[0])
        } else {
            // Round trip: Show both selected dates
            let sortedDates = searchViewModel.selectedDates.sorted()
            return "\(formatDateForDisplay(sortedDates[0])) - \(formatDateForDisplay(sortedDates[1]))"
        }
    }



    private func getDateTextColor() -> Color {
        if searchViewModel.selectedDates.isEmpty {
            return .gray
        }
        return .primary
    }
    
    private func animatedSwapLocations() {
        // Animate 360 degrees rotation
        withAnimation(.easeInOut(duration: 0.6)) {
            swapRotationDegrees += 360
        }

        // Delay swap logic to align with animation duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Perform swap halfway through animation for smoothness
            let tempLocation = searchViewModel.fromLocation
            let tempCode = searchViewModel.fromIataCode
            
            searchViewModel.fromLocation = searchViewModel.toLocation
            searchViewModel.fromIataCode = searchViewModel.toIataCode
            
            searchViewModel.toLocation = tempLocation
            searchViewModel.toIataCode = tempCode
        }
    }


    
    private var updatedSearchButton: some View {
           VStack(spacing: 4) {
               Button(action: performSearch) {
                   Text("Search Flights")
                       .font(.system(size: 16, weight: .semibold))
                       .foregroundColor(.white)
                       .frame(maxWidth: .infinity)
                       .frame(height: 50)
                       .background(Color.orange)
                       .cornerRadius(8)
               }

               if showErrorMessage {
                   Label("Select location to search flight", systemImage: "exclamationmark.triangle")
                       .foregroundColor(.red)
                       .font(.system(size: 14))
                       .padding(.top, 4)
                       .transition(.opacity)
               }
           }
       }
       
    private func performSearch() {
        // Check if dates are not selected and set default dates
        if searchViewModel.selectedDates.isEmpty {
            let today = Date()
            let calendar = Calendar.current
            
            if searchViewModel.isRoundTrip {
                // For round trip: Use today as departure and today + 7 days as return
                let returnDate = calendar.date(byAdding: .day, value: 7, to: today) ?? today
                searchViewModel.selectedDates = [today, returnDate]
            } else {
                // For one-way: Use today as departure
                searchViewModel.selectedDates = [today]
            }
        }
        
        // Updated validation for required fields
        let valid: Bool
        if searchViewModel.selectedTab == 2 {
            valid = searchViewModel.multiCityTrips.allSatisfy { trip in
                !trip.fromIataCode.isEmpty && !trip.toIataCode.isEmpty
            }
        } else {
            valid = !searchViewModel.fromIataCode.isEmpty &&
                    !searchViewModel.toIataCode.isEmpty
                    // Removed the selectedDates.isEmpty check since we now set default dates
        }

        if valid {
            showErrorMessage = false
            
            // Execute search based on trip type
            if searchViewModel.selectedTab == 2 {
                // Multi-city search
                searchViewModel.executeMultiCitySearch()
            } else {
                // Regular search (one-way or round-trip)
                searchViewModel.executeSearch()
            }
        } else {
            withAnimation {
                showErrorMessage = true
            }
        }
    }

    
    enum LocationType {
        case from, to
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Trip Type Tabs
            tripTypeTabs
            
            if searchViewModel.selectedTab == 2 {
                updatedMultiCityInterface
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                
            } else {
                regularInterface
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: searchViewModel.selectedTab)
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingFromLocationSheet) {
            fromLocationSheet
        }
        .sheet(isPresented: $showingToLocationSheet) {
            toLocationSheet
        }
        .sheet(isPresented: $showingCalendar) {
            calendarSheet
        }
        .sheet(isPresented: $showingPassengersSheet) {
            PassengersAndClassSelector(
                adultsCount: $searchViewModel.adultsCount,
                childrenCount: $searchViewModel.childrenCount,
                selectedClass: $searchViewModel.selectedCabinClass,
                childrenAges: $searchViewModel.childrenAges
            )
        }
        
    }
    
    // MARK: - Computed Views
    
    private var tripTypeTabs: some View {
        let titles = ["Return", "One way", "Multi city"]
        let totalWidth = UIScreen.main.bounds.width * 0.6
        let tabWidth = totalWidth / 3
        let rightShift: CGFloat = 5
        
        return ZStack(alignment: .leading) {
            // Background capsule
            Capsule()
                .fill(Color(UIColor.systemGray6))
                .padding(.horizontal, -5)
                .padding(.vertical, -5)
            
            // Sliding white background for selected tab
            Capsule()
                .fill(Color.white)
                .frame(width: tabWidth - 10)
                .offset(x: (CGFloat(searchViewModel.selectedTab) * tabWidth) + rightShift)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: searchViewModel.selectedTab)
            
            // Tab buttons
            HStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    Button(action: {
                        searchViewModel.selectedTab = index
                        
                        if index == 2 {
                            searchViewModel.initializeMultiCityTrips()
                        } else {
                            let newIsRoundTrip = (index == 0)
                            searchViewModel.isRoundTrip = newIsRoundTrip
                            
                            if !newIsRoundTrip && searchViewModel.selectedDates.count > 1 {
                                searchViewModel.selectedDates = Array(searchViewModel.selectedDates.prefix(1))
                            }
                        }
                    }) {
                        Text(titles[index])
                            .font(.system(size: 13, weight: searchViewModel.selectedTab == index ? .semibold : .regular))
                            .foregroundColor(searchViewModel.selectedTab == index ? .blue : .primary)
                            .frame(width: tabWidth)
                            .padding(.vertical, 8)
                    }
                }
            }
        }
        .frame(width: totalWidth, height: 36)
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }

    
    // MARK: - Updated Multi-City Interface with Enhanced Animations
       private var updatedMultiCityInterface: some View {
           VStack(spacing: 16) {
               // Flight segments with enhanced animations
               VStack(spacing: 12) {
                   ForEach(searchViewModel.multiCityTrips.indices, id: \.self) { index in
                       HomeMultiCitySegmentView(
                        searchViewModel: searchViewModel, trip: searchViewModel.multiCityTrips[index],
                           index: index,
                           canRemove: searchViewModel.multiCityTrips.count > 2,
                           isLastRow: false,
                           onFromTap: {
                               editingTripIndex = index
                               editingFromOrTo = .from
                               showingFromLocationSheet = true
                           },
                           onToTap: {
                               editingTripIndex = index
                               editingFromOrTo = .to
                               showingToLocationSheet = true
                           },
                           onDateTap: {
                               editingTripIndex = index
                               showingCalendar = true
                           },
                           onRemove: {
                               removeTrip(at: index)
                           }
                       )
                       .matchedGeometryEffect(id: "trip-\(searchViewModel.multiCityTrips[index].id)", in: tripAnimation)
                       .transition(.asymmetric(
                           insertion: .move(edge: .bottom)
                               .combined(with: .opacity)
                               .combined(with: .scale(scale: 0.8)),
                           removal: .move(edge: .trailing)
                               .combined(with: .opacity)
                               .combined(with: .scale(scale: 0.6))
                       ))
                   }
               }
               .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3), value: searchViewModel.multiCityTrips.count)
               
               VStack(spacing: 0) {
                   Divider()
                       .padding(.horizontal, -20)
                   
                   HStack(spacing: 0) {
                       // Passenger selection button
                       Button(action: {
                           showingPassengersSheet = true
                       }) {
                           HStack(spacing: 12) {
                               Image(systemName: "person.fill")
                                   .foregroundColor(.primary)
                                   .frame(width: 20, height: 20)

                               Text(passengerDisplayText)
                                   .font(.system(size: 16, weight: .medium))
                                   .foregroundColor(.primary)

                               Spacer()
                           }
                           .padding(.vertical, 16)
                           .padding(.leading, 10)
                       }
                       .frame(maxHeight: .infinity)

                       // Vertical Divider and Add Flight Button with Animation
                       if searchViewModel.multiCityTrips.count < 4 {
                           Rectangle()
                               .frame(width: 1)
                               .foregroundColor(Color.gray.opacity(0.3))
                               .frame(maxHeight: .infinity)
                               .transition(.opacity.combined(with: .scale(scale: 0.1, anchor: .center)))

                           Spacer()

                           if canAddTrip {
                               Button(action: addTrip) {
                                   HStack(spacing: 8) {
                                       Image(systemName: "plus")
                                           .foregroundColor(.blue)
                                           .font(.system(size: 16, weight: .semibold))

                                       Text("Add flight")
                                           .font(.system(size: 16, weight: .semibold))
                                           .foregroundColor(.blue)
                                   }
                                   .padding(.vertical, 16)
                                   .padding(.trailing, 12)
                                   .background(
                                       RoundedRectangle(cornerRadius: 8)
                                           .fill(Color.blue.opacity(0.1))
                                           .opacity(0)
                                   )
                               }
                               .frame(maxHeight: .infinity)
                               .scaleEffect(searchViewModel.multiCityTrips.count >= 4 ? 0.95 : 1.0)
                               .transition(.asymmetric(
                                   insertion: .move(edge: .trailing).combined(with: .opacity),
                                   removal: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.1))
                               ))

                           }
                           
                                                  }
                   }
                   .background(Color.white)
                   .frame(minHeight: 64)
                   .animation(.spring(response: 0.5, dampingFraction: 0.7), value: searchViewModel.multiCityTrips.count)
                   
                   if searchViewModel.multiCityTrips.count < 5 {
                       Divider()
                           .padding(.horizontal, -20)
                           .transition(.opacity.combined(with: .move(edge: .bottom)))
                   }
               }
               .animation(.easeInOut(duration: 0.3), value: searchViewModel.multiCityTrips.count < 5)

               // Search button
               searchButton
               
               // Direct flights toggle
               directFlightsToggle
           }
       }
    
    private var regularInterface: some View {
        VStack(spacing: 12) {
            fromLocationButton
            ZStack {
                Divider()
                    .padding(.leading,40)
                    .padding(.trailing,-20)
                swapButton
            }
            toLocationButton
            Divider()
                .padding(.leading,40)
                .padding(.trailing,-20)
            dateButton
            Divider()
                .padding(.leading,40)
                .padding(.trailing,-20)
            passengerButton
            searchButton
            directFlightsToggle
        }
    }
    
    private var fromLocationButton: some View {
        Button(action: {
            showingFromLocationSheet = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "airplane.departure")
                    .foregroundColor(.primary)
                    .frame(width: 20, height: 20)
                
                HStack(spacing: 5) {
                    Text(getFromLocationDisplayText())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(getFromLocationTextColor())
                    Text(searchViewModel.fromLocation)
                        .font(.system(size: 16, weight: .medium))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(getFromLocationNameTextColor())
                }
                
                Spacer()
            }
            .padding(.top, 12)
            .padding(.horizontal, 12)
        }
    }
    private var swapButton: some View {
        HStack {
            Spacer()
            Button(action: {
                animatedSwapLocations()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 48, height: 48)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "arrow.up.arrow.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.blue)
                        .rotationEffect(.degrees(swapRotationDegrees))
                        .animation(.easeInOut(duration: 0.3), value: swapRotationDegrees)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
    }

    
    private var toLocationButton: some View {
        Button(action: {
            showingToLocationSheet = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "airplane.arrival")
                    .foregroundColor(.primary)
                    .frame(width: 20, height: 20)
                
                HStack(spacing: 5) {
                    Text(getToLocationDisplayText())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(getToLocationTextColor())
                    Text(searchViewModel.toLocation)
                        .font(.system(size: 16, weight: .medium))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(getToLocationNameTextColor())
                }
     
                Spacer()
            }
            .padding(.bottom, 12)
            .padding(.horizontal, 12)
        }
    }
    
    private var dateButton: some View {
        Button(action: {
            showingCalendar = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .foregroundColor(.primary)
                    .frame(width: 20, height: 20)
                
                Text(getDateDisplayText())
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(getDateTextColor())
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
        }
    }
    
    private var passengerButton: some View {
        Button(action: {
            showingPassengersSheet = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .foregroundColor(.primary)
                    .frame(width: 20, height: 20)
                
                Text(passengerDisplayText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
           
        }
//        .offset(y: searchViewModel.selectedTab == 2 ? 0 : -12)
    }
    
    private var searchButton: some View {
        VStack(spacing: 4) {
            Button(action: performSearch) {
                Text("Search Flights")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
            // Always enabled, so no .disabled here

            if showErrorMessage {
                Label("Select location to search flight",systemImage: "exclamationmark.triangle")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding(.top, 4)
                    .transition(.opacity)
            }
        }
    }
    
    private var directFlightsToggle: some View {
            HStack(spacing: 8) {
                Text("Direct flights only")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)

                // UPDATED: Use searchViewModel.directFlightsOnly instead of local state
                Toggle("", isOn: $searchViewModel.directFlightsOnly)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            .padding(.horizontal, 4)
        }

    
    private var addFlightButton: some View {
        Button(action: addTrip) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                Text("Add flight")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Sheet Views
    
    @ViewBuilder
    private var fromLocationSheet: some View {
        if searchViewModel.selectedTab == 2 {
            HomeMultiCityLocationSheet(
                searchViewModel: searchViewModel,
                tripIndex: editingTripIndex,
                isFromLocation: editingFromOrTo == .from
            )
        } else {
            HomeFromLocationSearchSheet(searchViewModel: searchViewModel)
        }
    }
    
    @ViewBuilder
    private var toLocationSheet: some View {
        if searchViewModel.selectedTab == 2 {
            HomeMultiCityLocationSheet(
                searchViewModel: searchViewModel,
                tripIndex: editingTripIndex,
                isFromLocation: false
            )
        } else {
            HomeToLocationSearchSheet(searchViewModel: searchViewModel)
        }
    }
    
    @ViewBuilder
    private var calendarSheet: some View {
        if searchViewModel.selectedTab == 2 {
            // Multi-city calendar - use CalendarView
            CalendarView(
                fromiatacode: .constant(""),
                toiatacode: .constant(""),
                parentSelectedDates: .constant([]),
                isMultiCity: true,
                multiCityTripIndex: editingTripIndex,
                sharedMultiCityViewModel: searchViewModel
            )
        } else {
            HomeCalendarSheet(searchViewModel: searchViewModel)
        }
    }
    // MARK: - Computed Properties
    
    private var canSearch: Bool {
        if searchViewModel.selectedTab == 2 {
            return searchViewModel.multiCityTrips.allSatisfy { trip in
                !trip.fromIataCode.isEmpty && !trip.toIataCode.isEmpty
            }
        } else {
            return !searchViewModel.fromIataCode.isEmpty &&
                   !searchViewModel.toIataCode.isEmpty &&
                   !searchViewModel.selectedDates.isEmpty
        }
    }
    
    private var dateDisplayText: String {
        if searchViewModel.selectedDates.isEmpty {
            return "Select dates"
        } else if searchViewModel.selectedDates.count == 1 {
            return formatDateForDisplay(searchViewModel.selectedDates[0])
        } else {
            let sortedDates = searchViewModel.selectedDates.sorted()
            return "\(formatDateForDisplay(sortedDates[0])) - \(formatDateForDisplay(sortedDates[1]))"
        }
    }
    
    private var passengerDisplayText: String {
        let totalPassengers = searchViewModel.adultsCount + searchViewModel.childrenCount
        return "\(totalPassengers) Adult\(totalPassengers > 1 ? "s" : "") - \(searchViewModel.selectedCabinClass)"
    }
    
    // MARK: - Helper Methods
    
    private func formatDateForDisplay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E,d MMM"
        return formatter.string(from: date)
    }
    
    private func swapLocations() {
        let tempLocation = searchViewModel.fromLocation
        let tempCode = searchViewModel.fromIataCode
        
        searchViewModel.fromLocation = searchViewModel.toLocation
        searchViewModel.fromIataCode = searchViewModel.toIataCode
        
        searchViewModel.toLocation = tempLocation
        searchViewModel.toIataCode = tempCode
    }
    
    private func addTrip() {
         guard searchViewModel.multiCityTrips.count < 5,
               let lastTrip = searchViewModel.multiCityTrips.last else { return }
         
         let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: lastTrip.date) ?? Date()
         
         let newTrip = MultiCityTrip(
             fromLocation: lastTrip.toLocation,
             fromIataCode: lastTrip.toIataCode,
             toLocation: "Where to?",
             toIataCode: "",
             date: nextDay
         )
         
         // Native iOS spring animation with haptic feedback
         let impactFeedback = UIImpactFeedbackGenerator(style: .light)
         impactFeedback.impactOccurred()
         
         withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
             searchViewModel.multiCityTrips.append(newTrip)
         }
         
         // Add a slight delay and then focus on the new trip's destination
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
             // Optional: Auto-focus on the new trip's destination field
             editingTripIndex = searchViewModel.multiCityTrips.count - 1
             editingFromOrTo = .to
             
             // Add a subtle scale animation to highlight the new row
             withAnimation(.easeInOut(duration: 0.3)) {
                 // This could trigger a highlight state if needed
             }
         }
     }
    
    
    private func removeTrip(at index: Int) {
           guard searchViewModel.multiCityTrips.count > 2,
                 index < searchViewModel.multiCityTrips.count else { return }
           
           // Haptic feedback for deletion
           let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
           impactFeedback.impactOccurred()
           
           withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2)) {
               searchViewModel.multiCityTrips.remove(at: index)
           }
       }
    
    

}

// MARK: - Home Multi-City Segment View
struct HomeMultiCitySegmentView: View {
    
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    let trip: MultiCityTrip
    let index: Int
    let canRemove: Bool
    let isLastRow: Bool
    let onFromTap: () -> Void
    let onToTap: () -> Void
    let onDateTap: () -> Void
    let onRemove: () -> Void
    
    // Helper methods for dynamic colors
    private func getFromLocationTextColor() -> Color {
        if trip.fromIataCode.isEmpty {
            return .gray
        }
        return .primary
    }
    
    private func getFromLocationNameTextColor() -> Color {
        if trip.fromLocation.isEmpty {
            return .gray
        }
        return .primary
    }
    
    private func getToLocationTextColor() -> Color {
        if trip.toIataCode.isEmpty {
            return .gray
        }
        return .primary
    }
    
    private func getToLocationNameTextColor() -> Color {
        if trip.toLocation.isEmpty {
            return .gray
        }
        return .primary
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top horizontal line - always drawn
            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.vertical, 8)
                .padding(.horizontal,-20)
            
            HStack(spacing: 0) {
                // From Location Column
                // From Location Column
                Button(action: onFromTap) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trip.fromIataCode.isEmpty ? "" : trip.fromIataCode)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(getFromLocationTextColor())
                        Text(trip.fromLocation.isEmpty || trip.fromLocation == "Departure?" ? "Departure?" : trip.fromLocation)
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundColor(getFromLocationNameTextColor())
                    }
                    .padding(.horizontal, 8)
                }
              
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .frame(width: 1, height: 76)
                    .background(Color.gray.opacity(0.3))
                    .padding(.top,10)
                
                // To Location Column
                // To Location Column
                Button(action: onToTap) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trip.toIataCode.isEmpty ? "" : trip.toIataCode)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(getToLocationTextColor())
                        Text(trip.toLocation.isEmpty || trip.toLocation == "Destination?" ? "Destination?" : trip.toLocation)
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundColor(getToLocationNameTextColor())
                    }
                    .padding(.horizontal, 8)
                }
                

                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .frame(width: 1, height: 76)
                    .background(Color.gray.opacity(0.3))
                    .padding(.top,10)
                
                // Date Column
                Button(action: onDateTap) {
                    Text(trip.compactDisplayDate)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: 100, alignment: .leading)
                }
                
                
                Divider()
                    .frame(width: 1, height: 76)
                    .background(Color.gray.opacity(0.3))
                    .padding(.top,10)
                
                // Remove Button Column
                if canRemove {
                    Button(action: onRemove) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                    }
                } else {
                    Spacer().frame(width: 40)
                }
            }
            .frame(height: 48)
            
        }
        
    }
}




// MARK: - Updated Home Multi-City Location Sheet with Recent Searches

struct HomeMultiCityLocationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    let tripIndex: Int
    let isFromLocation: Bool
    
    @State private var searchText = ""
    @State private var results: [AutocompleteResult] = []
    @State private var isSearching = false
    @State private var searchError: String? = nil
    @FocusState private var isTextFieldFocused: Bool
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showRecentSearches = true
    
    // Add recent search manager
    @ObservedObject private var recentSearchManager = RecentLocationSearchManager.shared
    
    private let searchDebouncer = SearchDebouncer(delay: 0.3)

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text(isFromLocation ? "From Where?" : "Where to?")
                    .font(.headline)
                
                Spacer()
                
                // Empty space to balance the X button
                Image(systemName: "xmark")
                    .font(.system(size: 18))
                    .foregroundColor(.clear)
            }
            .padding()
            
            // Search bar
            HStack {
                TextField(isFromLocation ? "Origin City, Airport or place" : "Destination City, Airport or place", text: $searchText)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange, lineWidth: 2)
                    )
                    .cornerRadius(8)
                    .focused($isTextFieldFocused)
                    .onChange(of: searchText) {
                        handleTextChange()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        results = []
                        showRecentSearches = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.top)
            
            // Results section with recent searches
            if isSearching {
                VStack {
                    ProgressView()
                    Text("Searching...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                Spacer()
            } else if let error = searchError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
                Spacer()
            } else if !results.isEmpty {
                // Show search results
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(results) { result in
                            LocationResultRow(result: result)
                                .onTapGesture {
                                    selectLocation(result: result)
                                }
                        }
                    }
                }
            } else if showRecentSearches && searchText.isEmpty {
                // Show recent searches when no active search
                RecentLocationSearchView(
                    onLocationSelected: { result in
                        selectLocation(result: result)
                    },
                    showAnywhereOption: false
                )
                Spacer()
            } else if shouldShowNoResults() {
                Text("No results found")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                RecentLocationSearchView(
                    onLocationSelected: { result in
                        selectLocation(result: result)
                    },
                    showAnywhereOption: false
                )
                Spacer()
            }
        }
        .background(Color.white)
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func handleTextChange() {
        showRecentSearches = searchText.isEmpty
        
        if !searchText.isEmpty {
            searchDebouncer.debounce {
                searchLocations(query: searchText)
            }
        } else {
            results = []
        }
    }
    
    private func shouldShowNoResults() -> Bool {
        return results.isEmpty && !searchText.isEmpty && !showRecentSearches
    }
    
    private func selectLocation(result: AutocompleteResult) {
        // IMPORTANT: Add to recent searches before processing
        recentSearchManager.addRecentSearch(result)
        
        if isFromLocation {
            searchViewModel.multiCityTrips[tripIndex].fromLocation = result.cityName
            searchViewModel.multiCityTrips[tripIndex].fromIataCode = result.iataCode
        } else {
            searchViewModel.multiCityTrips[tripIndex].toLocation = result.cityName
            searchViewModel.multiCityTrips[tripIndex].toIataCode = result.iataCode
        }
        
        searchText = result.cityName
        dismiss()
    }
    
    private func searchLocations(query: String) {
        guard !query.isEmpty else {
            results = []
            return
        }
        
        isSearching = true
        searchError = nil
        
        ExploreAPIService.shared.fetchAutocomplete(query: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isSearching = false
                if case .failure(let error) = completion {
                    searchError = error.localizedDescription
                }
            }, receiveValue: { results in
                self.results = results
            })
            .store(in: &cancellables)
    }
}



// MARK: - Home Collapsible Search Input (matching style)
struct HomeCollapsibleSearchInput: View {
    @Binding var isExpanded: Bool
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded = true
            }
        }) {
            

                
                // Route display
                HStack(spacing: 8) {
                    // From
             

                        Text(searchViewModel.fromIataCode.isEmpty ? "FROM" : searchViewModel.fromIataCode)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                  
                    
                   Text("-")
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    // To
 
                        Text(searchViewModel.toIataCode.isEmpty ? "TO" : searchViewModel.toIataCode)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 4, height: 4)
   
                    
                    // Date display (if selected)
                    if !searchViewModel.selectedDates.isEmpty {
              
 
                            Text(formatDatesForCollapsed())
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            Spacer()
                        
                    }

                    
                    Spacer()
                    
                    Text("Search")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: 105)
                                .frame(height: 44)
                                .background(
                                    RoundedCorners(tl: 8, tr: 26, bl: 8, br: 26)
                                        .fill(Color.orange)
                                )
                }
                .padding(4)
                .padding(.leading,16)
                
            .background(Color.white)
            .cornerRadius(26)
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color.orange, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
    }
    
    private func formatDatesForDisplay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E,d MMM"
        
        if searchViewModel.selectedDates.count >= 2 {
            let sortedDates = searchViewModel.selectedDates.sorted()
            return "\(formatter.string(from: sortedDates[0])) - \(formatter.string(from: sortedDates[1]))"
        } else if searchViewModel.selectedDates.count == 1 {
            return formatter.string(from: searchViewModel.selectedDates[0])
        }
        return "Select dates"
    }
    
    private func formatDatesForCollapsed() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        
        if searchViewModel.selectedDates.count >= 2 {
            let sortedDates = searchViewModel.selectedDates.sorted()
            return "\(formatter.string(from: sortedDates[0])) - \(formatter.string(from: sortedDates[1]))"
        } else if searchViewModel.selectedDates.count == 1 {
            return formatter.string(from: searchViewModel.selectedDates[0])
        }
        return "Select dates"
    }
}




// MARK: - Updated Home Location Search Sheets with Recent Searches

struct HomeFromLocationSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    @State private var searchText = ""
    @State private var results: [AutocompleteResult] = []
    @State private var isSearching = false
    @State private var searchError: String? = nil
    @FocusState private var isTextFieldFocused: Bool
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showRecentSearches = true
    
    // Add recent search manager
    @ObservedObject private var recentSearchManager = RecentLocationSearchManager.shared
    
    private let searchDebouncer = SearchDebouncer(delay: 0.3)

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("From Where?")
                    .font(.headline)
                
                Spacer()
                
                // Empty space to balance the X button
                Image(systemName: "xmark")
                    .font(.system(size: 18))
                    .foregroundColor(.clear)
            }
            .padding()
            
            // Search bar
            HStack {
                TextField("Origin City, Airport or place", text: $searchText)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange, lineWidth: 2)
                    )
                    .cornerRadius(8)
                    .focused($isTextFieldFocused)
                    .onChange(of: searchText) {
                        handleTextChange()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        results = []
                        showRecentSearches = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            // Current location button
            Button(action: {
                useCurrentLocation()
            }) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    
                    Text("Use Current Location")
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .padding()
            }
            
            Divider()
            
            // Results section with recent searches
            if isSearching {
                VStack {
                    ProgressView()
                    Text("Searching...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                Spacer()
            } else if let error = searchError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
                Spacer()
            } else if !results.isEmpty {
                // Show search results
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(results) { result in
                            LocationResultRow(result: result)
                                .onTapGesture {
                                    selectLocation(result: result)
                                }
                        }
                    }
                }
            } else if showRecentSearches && searchText.isEmpty {
                // Show recent searches when no active search
                RecentLocationSearchView(
                    onLocationSelected: { result in
                        selectLocation(result: result)
                    },
                    showAnywhereOption: false
                )
                Spacer()
            } else if shouldShowNoResults() {
                Text("No results found")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                RecentLocationSearchView(
                    onLocationSelected: { result in
                        selectLocation(result: result)
                    },
                    showAnywhereOption: false
                )
                Spacer()
            }
        }
        .background(Color.white)
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func handleTextChange() {
        showRecentSearches = searchText.isEmpty
        
        if !searchText.isEmpty {
            searchDebouncer.debounce {
                searchLocations(query: searchText)
            }
        } else {
            results = []
        }
    }
    
    private func shouldShowNoResults() -> Bool {
        return results.isEmpty && !searchText.isEmpty && !showRecentSearches
    }
    
    private func useCurrentLocation() {
        searchViewModel.fromLocation = "Current Location"
        searchViewModel.fromIataCode = "DEL" // Using Delhi as default
        searchText = "Current Location"
        dismiss()
    }
    
    private func selectLocation(result: AutocompleteResult) {
        // IMPORTANT: Add to recent searches before processing
        recentSearchManager.addRecentSearch(result)
        
        // Check if this would match the current destination
        if !searchViewModel.toIataCode.isEmpty && result.iataCode == searchViewModel.toIataCode {
            searchError = "Origin and destination cannot be the same"
            return
        }
        
        searchViewModel.fromLocation = result.cityName
        searchViewModel.fromIataCode = result.iataCode
        searchText = result.cityName
        dismiss()
    }
    
    private func searchLocations(query: String) {
        guard !query.isEmpty else {
            results = []
            return
        }
        
        isSearching = true
        searchError = nil
        
        ExploreAPIService.shared.fetchAutocomplete(query: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isSearching = false
                if case .failure(let error) = completion {
                    searchError = error.localizedDescription
                }
            }, receiveValue: { results in
                self.results = results
            })
            .store(in: &cancellables)
    }
}

struct HomeToLocationSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    @State private var searchText = ""
    @State private var results: [AutocompleteResult] = []
    @State private var isSearching = false
    @State private var searchError: String? = nil
    @FocusState private var isTextFieldFocused: Bool
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showRecentSearches = true
    
    // Add recent search manager
    @ObservedObject private var recentSearchManager = RecentLocationSearchManager.shared
    
    private let searchDebouncer = SearchDebouncer(delay: 0.3)

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Where to?")
                    .font(.headline)
                
                Spacer()
                
                // Empty space to balance the X button
                Image(systemName: "xmark")
                    .font(.system(size: 18))
                    .foregroundColor(.clear)
            }
            .padding()
            
            // Search bar
            HStack {
                TextField("Destination City, Airport or place", text: $searchText)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange, lineWidth: 2)
                    )
                    .cornerRadius(8)
                    .focused($isTextFieldFocused)
                    .onChange(of: searchText) {
                        handleTextChange()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        results = []
                        showRecentSearches = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.top)
            
            // Results section with recent searches
            if isSearching {
                VStack {
                    ProgressView()
                    Text("Searching...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                Spacer()
            } else if let error = searchError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
                Spacer()
            } else if !results.isEmpty {
                // Show search results (with Anywhere option at top)
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Show "Anywhere" option at the top for destination search
                        AnywhereOptionRow()
                            .onTapGesture {
                                handleAnywhereSelection()
                            }
                        
                        if !results.isEmpty {
                            Divider()
                                .padding(.horizontal)
                        }
                        
                        ForEach(results) { result in
                            LocationResultRow(result: result)
                                .onTapGesture {
                                    selectLocation(result: result)
                                }
                        }
                    }
                }
            } else if showRecentSearches && searchText.isEmpty {
                // Show recent searches when no active search (with Anywhere option)
                RecentLocationSearchView(
                    onLocationSelected: { result in
                        selectLocation(result: result)
                    },
                    showAnywhereOption: true,
                    onAnywhereSelected: {
                        handleAnywhereSelection()
                    }
                )
                Spacer()
            } else if shouldShowNoResults() {
                Text("No results found")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                RecentLocationSearchView(
                    onLocationSelected: { result in
                        selectLocation(result: result)
                    },
                    showAnywhereOption: true,
                    onAnywhereSelected: {
                        handleAnywhereSelection()
                    }
                )
                Spacer()
            }
        }
        .background(Color.white)
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func handleTextChange() {
        showRecentSearches = searchText.isEmpty
        
        if !searchText.isEmpty {
            searchDebouncer.debounce {
                searchLocations(query: searchText)
            }
        } else {
            results = []
        }
    }
    
    private func shouldShowNoResults() -> Bool {
        return results.isEmpty && !searchText.isEmpty && !showRecentSearches
    }
    
    private func handleAnywhereSelection() {
        searchViewModel.toLocation = "Anywhere"
        searchViewModel.toIataCode = ""
        searchText = "Anywhere"
        dismiss()
    }
    
    private func selectLocation(result: AutocompleteResult) {
        // IMPORTANT: Add to recent searches before processing
        recentSearchManager.addRecentSearch(result)
        
        // Check if this would match the current origin
        if !searchViewModel.fromIataCode.isEmpty && result.iataCode == searchViewModel.fromIataCode {
            searchError = "Origin and destination cannot be the same"
            return
        }
        
        searchViewModel.toLocation = result.cityName
        searchViewModel.toIataCode = result.iataCode
        searchText = result.cityName
        dismiss()
    }
    
    private func searchLocations(query: String) {
        guard !query.isEmpty else {
            results = []
            return
        }
        
        isSearching = true
        searchError = nil
        
        ExploreAPIService.shared.fetchAutocomplete(query: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isSearching = false
                if case .failure(let error) = completion {
                    searchError = error.localizedDescription
                }
            }, receiveValue: { results in
                self.results = results
            })
            .store(in: &cancellables)
    }
}
// MARK: - Home Calendar Sheet
struct HomeCalendarSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    
    var body: some View {
        CalendarView(
            fromiatacode: $searchViewModel.fromIataCode,
            toiatacode: $searchViewModel.toIataCode,
            parentSelectedDates: $searchViewModel.selectedDates,
            onAnytimeSelection: { results in
                dismiss()
            },
            onTripTypeChange: { newIsRoundTrip in
                searchViewModel.isRoundTrip = newIsRoundTrip
                searchViewModel.selectedTab = newIsRoundTrip ? 0 : 1
            },
            isRoundTrip: searchViewModel.isRoundTrip
        )
    }
}

// MARK: - Wrapper for Explore Results
struct ExploreResultsWrapperView: View {
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    
    var body: some View {
        ExploreScreenWithSearchData(
            fromLocation: searchViewModel.fromLocation,
            toLocation: searchViewModel.toLocation,
            fromIataCode: searchViewModel.fromIataCode,
            toIataCode: searchViewModel.toIataCode,
            selectedDates: searchViewModel.selectedDates,
            isRoundTrip: searchViewModel.isRoundTrip,
            adultsCount: searchViewModel.adultsCount,
            childrenCount: searchViewModel.childrenCount,
            childrenAges: searchViewModel.childrenAges,
            selectedCabinClass: searchViewModel.selectedCabinClass,
            selectedTab: searchViewModel.selectedTab,
            multiCityTrips: searchViewModel.multiCityTrips
        )
        .navigationBarHidden(true)
    }
}

// MARK: - Explore Screen with Search Data
struct ExploreScreenWithSearchData: View {
    // Search parameters
    let fromLocation: String
    let toLocation: String
    let fromIataCode: String
    let toIataCode: String
    let selectedDates: [Date]
    let isRoundTrip: Bool
    let adultsCount: Int
    let childrenCount: Int
    let childrenAges: [Int?]
    let selectedCabinClass: String
    let selectedTab: Int
    let multiCityTrips: [MultiCityTrip]
    
    @StateObject private var viewModel = ExploreViewModel()
    @State private var currentSelectedTab: Int = 0
    @State private var currentIsRoundTrip: Bool = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Use the existing ExploreScreen body content
        VStack(spacing: 0) {
            // Custom navigation bar
            VStack(spacing: 0) {
                HStack {
                    // Back button (goes back to home)
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    Spacer()
                                        
                    // Centered trip type tabs
                    TripTypeTabView(selectedTab: $currentSelectedTab, isRoundTrip: $currentIsRoundTrip, viewModel: viewModel)
                        .frame(width: UIScreen.main.bounds.width * 0.55)
                                        
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .padding(.top,5)
                
                // Search card with dynamic values
                SearchCard(viewModel: viewModel, isRoundTrip: $currentIsRoundTrip, selectedTab: currentSelectedTab)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                    
                    if viewModel.isLoading || viewModel.isLoadingFlights {
                        LoadingBorderView()
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange, lineWidth: 1)
                    }
                }
            )
            .padding()
            
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    // Show detailed flight list directly
                    ModifiedDetailedFlightListView(viewModel: viewModel)
                        .edgesIgnoringSafeArea(.all)
                        .background(Color(.systemBackground))
                }
                .background(Color("scroll"))
            }
            .background(Color(.systemBackground))
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            // Initialize local state with passed values
            currentSelectedTab = selectedTab
            currentIsRoundTrip = isRoundTrip
            transferSearchDataAndInitiateSearch()
        }
    }
    
    private func transferSearchDataAndInitiateSearch() {
        // Transfer all search data to the view model
        viewModel.fromLocation = fromLocation
        viewModel.toLocation = toLocation
        viewModel.fromIataCode = fromIataCode
        viewModel.toIataCode = toIataCode
        viewModel.dates = selectedDates
        viewModel.isRoundTrip = isRoundTrip
        viewModel.adultsCount = adultsCount
        viewModel.childrenCount = childrenCount
        viewModel.childrenAges = childrenAges
        viewModel.selectedCabinClass = selectedCabinClass
        viewModel.multiCityTrips = multiCityTrips
        
        // Set the selected origin and destination codes
        viewModel.selectedOriginCode = fromIataCode
        viewModel.selectedDestinationCode = toIataCode
        
        // Mark as direct search to show detailed flight list
        viewModel.isDirectSearch = true
        viewModel.showingDetailedFlightList = true
        
        // Handle multi-city vs regular search
        if selectedTab == 2 && !multiCityTrips.isEmpty {
            // Multi-city search
            viewModel.searchMultiCityFlights()
        } else {
            // Regular search - format dates for API
            if !selectedDates.isEmpty {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                if selectedDates.count >= 2 {
                    let sortedDates = selectedDates.sorted()
                    viewModel.selectedDepartureDatee = formatter.string(from: sortedDates[0])
                    viewModel.selectedReturnDatee = formatter.string(from: sortedDates[1])
                } else if selectedDates.count == 1 {
                    viewModel.selectedDepartureDatee = formatter.string(from: selectedDates[0])
                    if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDates[0]) {
                        viewModel.selectedReturnDatee = formatter.string(from: nextDay)
                    }
                }
            }
            
            // Initiate the regular search
            viewModel.searchFlightsForDates(
                origin: fromIataCode,
                destination: toIataCode,
                returnDate: isRoundTrip ? viewModel.selectedReturnDatee : "",
                departureDate: viewModel.selectedDepartureDatee,
                isDirectSearch: true
            )
        }
    }
}

// MARK: - Helper Classes (renamed to avoid conflicts)
class SearchDebouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        
        let workItem = DispatchWorkItem(block: action)
        self.workItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}

// MARK: - Scroll Offset Preference Key
 struct ScrollOffsetPreferenceKeyy: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}


