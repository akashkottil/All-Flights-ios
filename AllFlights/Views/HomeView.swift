import SwiftUI
import Combine

// MARK: - Shared View Model for Home and Explore
class SharedFlightSearchViewModel: ObservableObject {
    @Published var fromLocation = "Departure?"
    @Published var toLocation = "Destination?"
    @Published var fromIataCode: String = "DEL" // Default to Delhi
    @Published var toIataCode: String = ""
    
    @Published var selectedDates: [Date] = []
    @Published var isRoundTrip: Bool = true
    @Published var selectedTab = 0 // 0: Return, 1: One way, 2: Multi city
    
    @Published var adultsCount = 1
    @Published var childrenCount = 0
    @Published var childrenAges: [Int?] = []
    @Published var selectedCabinClass = "Economy"
    
    @Published var multiCityTrips: [MultiCityTrip] = []
    
    // Search results
    @Published var shouldNavigateToResults = false
    @Published var searchExecuted = false
    
    // Use the shared recent search manager
        var recentSearchManager: RecentSearchManager {
            return RecentSearchManager.shared
        }
       
    // Initialize multi-city trips
        func initializeMultiCityTrips() {
            let calendar = Calendar.current
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: Date()) ?? Date()
            
            multiCityTrips = [
                MultiCityTrip(fromLocation: fromLocation, fromIataCode: fromIataCode,
                             toLocation: toLocation, toIataCode: toIataCode, date: tomorrow),
                MultiCityTrip(fromLocation: toLocation, fromIataCode: toIataCode,
                             toLocation: "", toIataCode: "", date: dayAfterTomorrow)
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
    
    // Reset search state
       func resetSearch() {
           shouldNavigateToResults = false
           searchExecuted = false
       }
       
       // Updated executeSearch to automatically save to recent searches
       func executeSearch() {
           // Save to recent searches before executing the search
           saveToRecentSearches()
           
           // Execute the search
           searchExecuted = true
           shouldNavigateToResults = true
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

// MARK: - Enhanced HomeView
struct HomeView: View {
    @State private var isSearchExpanded = true
    @State private var navigateToAccount = false
    @Namespace private var animation
    @GestureState private var dragOffset: CGFloat = 0
    
    // Shared view model for search functionality
    @StateObject private var searchViewModel = SharedFlightSearchViewModel()
    
    // Navigation to explore results
    @State private var showingExploreResults = false

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
                // Scrollable content below the header + search
                ScrollView {
                    VStack(spacing: 0) {
                        GeometryReader { geo in
                            Color.clear
                                .preference(
                                    key: ScrollOffsetPreferenceKeyy.self,
                                    value: geo.frame(in: .named("scroll")).minY
                                )
                        }
                        .frame(height: 0)

                        VStack(alignment: .leading, spacing: 16) {
                            updatedRecentSearchSection
                            HStack(spacing: 4) {
                                Text("Cheapest Fares From ")
                                + Text("Kochi").foregroundColor(.blue)

                                Image(systemName: "chevron.down")
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal)

                            CheapFlights()
                            FeatureCards()
                            LoginNotifier()
                            ratingPrompt
                            BottomSignature()
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKeyy.self) { value in
                    let threshold: CGFloat = -40
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        isSearchExpanded = value > threshold
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToAccount) {
                AccountView()
            }
            .navigationDestination(isPresented: $showingExploreResults) {
                ExploreResultsWrapperView(searchViewModel: searchViewModel)
            }
        }
        .scrollIndicators(.hidden)
        .onChange(of: searchViewModel.shouldNavigateToResults) { shouldNavigate in
            if shouldNavigate {
                showingExploreResults = true
                searchViewModel.resetSearch()
            }
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
        .padding(.bottom, 10)

    }

    // MARK: - Updated Recent Search Section
    var updatedRecentSearchSection: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Recent Search")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                    Spacer()
                    Button(action: {
                        // Use the shared recent search manager
                        RecentSearchManager.shared.clearAllRecentSearches()
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
        
    }
}

// MARK: - Enhanced Search Input Component (exact UI match)
struct EnhancedSearchInput: View {
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    @State private var showingFromLocationSheet = false
    @State private var showingToLocationSheet = false
    @State private var showingCalendar = false
    @State private var showingPassengersSheet = false
    @State private var directFlightsOnly = false
    @State private var editingTripIndex = 0
    @State private var editingFromOrTo: LocationType = .from
    
    @State private var showErrorMessage = false
    
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
           // Validation for required fields
           let valid: Bool
           if searchViewModel.selectedTab == 2 {
               valid = searchViewModel.multiCityTrips.allSatisfy { trip in
                   !trip.fromIataCode.isEmpty && !trip.toIataCode.isEmpty
               }
           } else {
               valid = !searchViewModel.fromIataCode.isEmpty &&
                       !searchViewModel.toIataCode.isEmpty &&
                       !searchViewModel.selectedDates.isEmpty
           }

           if valid {
               showErrorMessage = false
               // This will now automatically save to recent searches
               searchViewModel.executeSearch()
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
                multiCityInterface
            } else {
                regularInterface
            }
        }
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

    
    private var multiCityInterface: some View {
        VStack(spacing: 12) {
            // Multiple flight segments
            ForEach(0..<searchViewModel.multiCityTrips.count, id: \.self) { index in
                HomeMultiCitySegmentView(
                    trip: searchViewModel.multiCityTrips[index],
                    index: index,
                    canRemove: searchViewModel.multiCityTrips.count > 2,
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
            }
            
            // Add flight button
            if searchViewModel.multiCityTrips.count < 5 {
                addFlightButton
            }
            
            passengerButton
            searchButton
            directFlightsToggle
        }
    }
    
    private var regularInterface: some View {
        VStack(spacing: 12) {
            fromLocationButton
            ZStack {
                Divider()
                    .padding(.leading,40)
                swapButton
            }
            toLocationButton
            Divider()
                .padding(.leading,40)
            dateButton
            Divider()
                .padding(.leading,40)
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
                
             
                    Text(searchViewModel.fromLocation)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                
                
                Spacer()
            }
            .padding(.top, 12)
            .padding(.horizontal, 12)
           
        }
    }
    
    private var swapButton: some View {
        HStack {
            Spacer()
            Button(action: swapLocations) {
                Image("swap")
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 42, height: 42)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
           
        }
        .padding(.horizontal)
//        .offset(y: -6)
    }
    
    private var toLocationButton: some View {
        Button(action: {
            showingToLocationSheet = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "airplane.arrival")
                    .foregroundColor(.primary)
                    .frame(width: 20, height: 20)
                
              
                    Text(searchViewModel.toLocation)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
 
                
                Spacer()
            }
            .padding(.bottom, 12)
            .padding(.horizontal, 12)
            
        }
//        .offset(y: -12)
    }
    
    private var dateButton: some View {
        Button(action: {
            showingCalendar = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .foregroundColor(.primary)
                    .frame(width: 20, height: 20)
                
                Text(dateDisplayText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
           
        }
//        .offset(y: -12)
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

            Toggle("", isOn: $directFlightsOnly)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding(.horizontal, 4)
//        .offset(y: searchViewModel.selectedTab == 2 ? 0 : -12)

    }

    
    private var addFlightButton: some View {
        Button(action: addTrip) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
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
            HomeMultiCityCalendarSheet(
                searchViewModel: searchViewModel,
                tripIndex: editingTripIndex
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
        if searchViewModel.multiCityTrips.count < 5, let lastTrip = searchViewModel.multiCityTrips.last {
            let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: lastTrip.date) ?? Date()
            
            let newTrip = MultiCityTrip(
                fromLocation: lastTrip.toLocation,
                fromIataCode: lastTrip.toIataCode,
                toLocation: "Where to?",
                toIataCode: "",
                date: nextDay
            )
            
            searchViewModel.multiCityTrips.append(newTrip)
        }
    }
    
    private func removeTrip(at index: Int) {
        if searchViewModel.multiCityTrips.count > 2 {
            searchViewModel.multiCityTrips.remove(at: index)
        }
    }
    
    

}

// MARK: - Home Multi-City Segment View (renamed to avoid conflicts)
struct HomeMultiCitySegmentView: View {
    let trip: MultiCityTrip
    let index: Int
    let canRemove: Bool
    let onFromTap: () -> Void
    let onToTap: () -> Void
    let onDateTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // From Location with Remove button
            HStack {
                Button(action: onFromTap) {
                    HStack(spacing: 12) {
                        Image(systemName: "airplane.departure")
                            .foregroundColor(.gray)
                            .frame(width: 20, height: 20)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(trip.fromIataCode.isEmpty ? "FROM" : trip.fromIataCode)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                            Text(trip.fromLocation)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                if canRemove {
                    Button(action: onRemove) {
                        Text("Remove")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red)
                    }
                    .padding(.leading, 8)
                }
            }
            
            // To Location
            Button(action: onToTap) {
                HStack(spacing: 12) {
                    Image(systemName: "airplane.arrival")
                        .foregroundColor(.gray)
                        .frame(width: 20, height: 20)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(trip.toIataCode.isEmpty ? "TO" : trip.toIataCode)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        Text(trip.toLocation)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Date Selection
            Button(action: onDateTap) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                        .frame(width: 20, height: 20)
                    
                    Text(trip.displayDate)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.orange, lineWidth: 1)
        )
    }
}

// MARK: - Home Multi-City Location Sheet (renamed to avoid conflicts)
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
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.top)
            
            // Results
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
            } else if shouldShowNoResults() {
                Text("No results found")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
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
            }
        }
        .background(Color.white)
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func handleTextChange() {
        if !searchText.isEmpty {
            searchDebouncer.debounce {
                searchLocations(query: searchText)
            }
        } else {
            results = []
        }
    }
    
    private func shouldShowNoResults() -> Bool {
        return results.isEmpty && !searchText.isEmpty
    }
    
    private func selectLocation(result: AutocompleteResult) {
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

// MARK: - Home Multi-City Calendar Sheet (renamed to avoid conflicts)
struct HomeMultiCityCalendarSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    let tripIndex: Int
    @State private var tempSelectedDate: Date = Date()
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Select Date")
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    searchViewModel.multiCityTrips[tripIndex].date = tempSelectedDate
                    dismiss()
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            }
            .padding()
            
            // Simple date picker for multi-city
            DatePicker(
                "Select Date",
                selection: $tempSelectedDate,
                in: Date()...,
                displayedComponents: [.date]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()
            
            Spacer()
        }
        .onAppear {
            tempSelectedDate = searchViewModel.multiCityTrips[tripIndex].date
        }
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
            VStack(spacing: 12) {
                // Trip type tabs (collapsed version)
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { index in
                        let titles = ["Return", "One way", "Multi city"]
                        Text(titles[index])
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(searchViewModel.selectedTab == index ? .blue : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                }
                
                // Route display
                HStack(spacing: 8) {
                    // From
                    HStack(spacing: 4) {
                        Image(systemName: "airplane.departure")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                        Text(searchViewModel.fromIataCode.isEmpty ? "FROM" : searchViewModel.fromIataCode)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                    
                    // To
                    HStack(spacing: 4) {
                        Image(systemName: "airplane.arrival")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                        Text(searchViewModel.toIataCode.isEmpty ? "TO" : searchViewModel.toIataCode)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
                
                // Date display (if selected)
                if !searchViewModel.selectedDates.isEmpty {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                        Text(formatDatesForDisplay())
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
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
}



// MARK: - Home Location Search Sheets (renamed to avoid conflicts)
struct HomeFromLocationSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    @State private var searchText = ""
    @State private var results: [AutocompleteResult] = []
    @State private var isSearching = false
    @State private var searchError: String? = nil
    @FocusState private var isTextFieldFocused: Bool
    @State private var cancellables = Set<AnyCancellable>()
    
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
            
            // Results
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
            } else if shouldShowNoResults() {
                Text("No results found")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
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
            }
        }
        .background(Color.white)
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func handleTextChange() {
        if !searchText.isEmpty {
            searchDebouncer.debounce {
                searchLocations(query: searchText)
            }
        } else {
            results = []
        }
    }
    
    private func shouldShowNoResults() -> Bool {
        return results.isEmpty && !searchText.isEmpty
    }
    
    private func useCurrentLocation() {
        searchViewModel.fromLocation = "Current Location"
        searchViewModel.fromIataCode = "DEL" // Using Delhi as default
        searchText = "Current Location"
        dismiss()
    }
    
    private func selectLocation(result: AutocompleteResult) {
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
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.top)
            
            // Results
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
            } else if shouldShowNoResults() {
                Text("No results found")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
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
            }
        }
        .background(Color.white)
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func handleTextChange() {
        if !searchText.isEmpty {
            searchDebouncer.debounce {
                searchLocations(query: searchText)
            }
        } else {
            results = []
        }
    }
    
    private func shouldShowNoResults() -> Bool {
        return results.isEmpty && !searchText.isEmpty
    }
    
    private func selectLocation(result: AutocompleteResult) {
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
        
        // Format dates for API
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
        
        // Initiate the search
        if selectedTab == 2 {
            // Multi-city search
            viewModel.searchMultiCityFlights()
        } else {
            // Regular search
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
