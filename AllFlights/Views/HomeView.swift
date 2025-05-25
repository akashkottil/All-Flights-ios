import SwiftUI
import Combine

// MARK: - Shared View Model for Home and Explore
class SharedFlightSearchViewModel: ObservableObject {
    @Published var fromLocation = "Current Location"
    @Published var toLocation = "Where to?"
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
    
    // Trigger search
    func executeSearch() {
        searchExecuted = true
        shouldNavigateToResults = true
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
            ZStack(alignment: .top) {
                Color("AppPrimaryColor")
                    .frame(height: UIScreen.main.bounds.height * 0.3)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Sticky header
                    headerView
                        .zIndex(1)

                    ScrollView {
                        VStack(spacing: 0) {
                            // GeometryReader for scroll detection
                            GeometryReader { geo in
                                Color.clear
                                    .preference(
                                        key: ScrollOffsetPreferenceKey.self,
                                        value: geo.frame(in: .named("scroll")).minY
                                    )
                            }
                            .frame(height: 0)

                            // Enhanced Search Section
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
                            .padding(.bottom, 10)

                            // Scrollable content
                            VStack(spacing: 16) {
                                recentSearchSection
                                CheapFlights()
                                FeatureCards()
                                LoginNotifier()
                                ratingPrompt
                                BottomSignature()
                            }
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        let threshold: CGFloat = -40
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isSearchExpanded = value > threshold
                        }
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
                .frame(width: 25, height: 25)
                .cornerRadius(6)
                .padding(.trailing, 4)

            Text("All Flights")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Spacer()

            Image("homeProfile")
                .resizable()
                .frame(width: 30, height: 30)
                .cornerRadius(6)
                .padding(.trailing, 4)
                .onTapGesture {
                    navigateToAccount = true
                }
        }
        .padding(.horizontal, 25)
        .padding(.top, 20)
        .padding(.bottom, 10)
        .background(Color("AppPrimaryColor").ignoresSafeArea(edges: .top))
    }

    // MARK: - Recent Search Section
    var recentSearchSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Search")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                Spacer()
                Text("Clear All")
                    .foregroundColor(Color("ThridColor"))
                    .font(.system(size: 14))
                    .fontWeight(.bold)
            }
            .padding(.horizontal)

            RecentSearch()
        }
    }

    // MARK: - Rating Prompt
    var ratingPrompt: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("gradientBlueLeft"), Color("gradientBlueRight")]),
                startPoint: .leading,
                endPoint: .trailing
            )
            HStack {
                Image("starImg")
                Spacer()
                VStack(alignment: .leading) {
                    Text("How do you feel?")
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                    Text("Rate us On Appstore")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
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
        .cornerRadius(12)
    }
}

// MARK: - Enhanced Search Input Component
struct EnhancedSearchInput: View {
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    @State private var showingFromLocationSheet = false
    @State private var showingToLocationSheet = false
    @State private var showingCalendar = false
    @State private var showingPassengersSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Trip Type Tabs
            HomeTripTypeTabsView(searchViewModel: searchViewModel)
                .padding(.bottom, 16)
            
            VStack(spacing: 12) {
                // From and To locations
                HStack(spacing: 12) {
                    // From location
                    Button(action: {
                        showingFromLocationSheet = true
                    }) {
                        HomeLocationButtonView(
                            icon: "airplane.departure",
                            title: "From",
                            location: searchViewModel.fromLocation,
                            isFrom: true
                        )
                    }
                    
                    // Swap button
                    Button(action: swapLocations) {
                        Image(systemName: "arrow.left.arrow.right")
                            .foregroundColor(.blue)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 40, height: 40)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    // To location
                    Button(action: {
                        showingToLocationSheet = true
                    }) {
                        HomeLocationButtonView(
                            icon: "airplane.arrival",
                            title: "To",
                            location: searchViewModel.toLocation,
                            isFrom: false
                        )
                    }
                }
                
                // Date and passenger selection
                HStack(spacing: 12) {
                    // Date button
                    Button(action: {
                        showingCalendar = true
                    }) {
                        HomeDateButtonView(searchViewModel: searchViewModel)
                    }
                    
                    // Passengers button
                    Button(action: {
                        showingPassengersSheet = true
                    }) {
                        HomePassengerButtonView(searchViewModel: searchViewModel)
                    }
                }
                
                // Search button
                Button(action: performSearch) {
                    Text("Search Flights")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(canSearch ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canSearch)
                .opacity(canSearch ? 1.0 : 0.6)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingFromLocationSheet) {
            HomeFromLocationSearchSheet(searchViewModel: searchViewModel)
        }
        .sheet(isPresented: $showingToLocationSheet) {
            HomeToLocationSearchSheet(searchViewModel: searchViewModel)
        }
        .sheet(isPresented: $showingCalendar) {
            HomeCalendarSheet(searchViewModel: searchViewModel)
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
    
    private var canSearch: Bool {
        !searchViewModel.fromIataCode.isEmpty &&
        !searchViewModel.toIataCode.isEmpty &&
        !searchViewModel.selectedDates.isEmpty
    }
    
    private func swapLocations() {
        let tempLocation = searchViewModel.fromLocation
        let tempCode = searchViewModel.fromIataCode
        
        searchViewModel.fromLocation = searchViewModel.toLocation
        searchViewModel.fromIataCode = searchViewModel.toIataCode
        
        searchViewModel.toLocation = tempLocation
        searchViewModel.toIataCode = tempCode
    }
    
    private func performSearch() {
        searchViewModel.executeSearch()
    }
}

// MARK: - Home Collapsible Search Input (renamed to avoid conflicts)
struct HomeCollapsibleSearchInput: View {
    @Binding var isExpanded: Bool
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded = true
            }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(searchViewModel.fromLocation) → \(searchViewModel.toLocation)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if !searchViewModel.selectedDates.isEmpty {
                        Text(formatDatesForDisplay())
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    } else {
                        Text("Select dates")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
    }
    
    private func formatDatesForDisplay() -> String {
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

// MARK: - Home Location Button View (renamed to avoid conflicts)
struct HomeLocationButtonView: View {
    let icon: String
    let title: String
    let location: String
    let isFrom: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Text(location)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Home Date Button View (renamed to avoid conflicts)
struct HomeDateButtonView: View {
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Date")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Text(dateDisplayText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var dateDisplayText: String {
        if searchViewModel.selectedDates.isEmpty {
            return "Select dates"
        } else if searchViewModel.selectedDates.count == 1 {
            return formatDate(searchViewModel.selectedDates[0])
        } else {
            let sortedDates = searchViewModel.selectedDates.sorted()
            return "\(formatDate(sortedDates[0])) - \(formatDate(sortedDates[1]))"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Home Passenger Button View (renamed to avoid conflicts)
struct HomePassengerButtonView: View {
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "person")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Passenger & Class")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Text("\(searchViewModel.adultsCount + searchViewModel.childrenCount), \(searchViewModel.selectedCabinClass)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Home Trip Type Tabs (renamed to avoid conflicts)
struct HomeTripTypeTabsView: View {
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    let tabs = ["Return", "One way", "Multi city"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
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
                    Text(tabs[index])
                        .font(.system(size: 14, weight: searchViewModel.selectedTab == index ? .semibold : .regular))
                        .foregroundColor(searchViewModel.selectedTab == index ? .blue : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            searchViewModel.selectedTab == index ?
                            Color.white : Color.clear
                        )
                        .cornerRadius(6)
                }
            }
        }
        .padding(4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
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
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
