import SwiftUI
import Combine

// MARK: - Shared Search Data Store
class SharedSearchDataStore: ObservableObject {
    static let shared = SharedSearchDataStore()
    
    // Search execution trigger
    @Published var shouldExecuteSearch = false
    @Published var searchTimestamp = Date()
    
    // Search parameters
    @Published var fromLocation = ""
    @Published var toLocation = ""
    @Published var fromIataCode = ""
    @Published var toIataCode = ""
    @Published var selectedDates: [Date] = []
    @Published var isRoundTrip = true
    @Published var selectedTab = 0 // 0: Return, 1: One way, 2: Multi city
    
    @Published var adultsCount = 1
    @Published var childrenCount = 0
    @Published var childrenAges: [Int?] = []
    @Published var selectedCabinClass = "Economy"
    
    @Published var multiCityTrips: [MultiCityTrip] = []
    
    // ADD: Direct flights preference
    @Published var directFlightsOnly = false
    
    // Navigation trigger
    @Published var shouldNavigateToExplore = false
    
    private init() {}
    
    // MARK: - Updated Execute Search Methods
    func executeSearchFromHome(
        fromLocation: String,
        toLocation: String,
        fromIataCode: String,
        toIataCode: String,
        selectedDates: [Date],
        isRoundTrip: Bool,
        selectedTab: Int,
        adultsCount: Int,
        childrenCount: Int,
        childrenAges: [Int?],
        selectedCabinClass: String,
        multiCityTrips: [MultiCityTrip],
        directFlightsOnly: Bool = false
    ) {
        // Store all search parameters
        self.fromLocation = fromLocation
        self.toLocation = toLocation
        self.fromIataCode = fromIataCode
        self.toIataCode = toIataCode
        self.selectedDates = selectedDates
        self.isRoundTrip = isRoundTrip
        self.selectedTab = selectedTab
        self.adultsCount = adultsCount
        self.childrenCount = childrenCount
        self.childrenAges = childrenAges
        self.selectedCabinClass = selectedCabinClass
        self.multiCityTrips = multiCityTrips
        self.directFlightsOnly = directFlightsOnly
        
        // Trigger navigation to explore tab
        shouldNavigateToExplore = true
        
        // Trigger search execution with a slight delay to ensure tab switch completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.shouldExecuteSearch = true
            self.searchTimestamp = Date()
        }
    }
    
    func resetSearch() {
        shouldExecuteSearch = false
        shouldNavigateToExplore = false
        directFlightsOnly = false
    }
    
    // Helper method to check if search data is valid
    var hasValidSearchData: Bool {
        if selectedTab == 2 {
            // Multi-city validation
            return multiCityTrips.allSatisfy { trip in
                !trip.fromIataCode.isEmpty && !trip.toIataCode.isEmpty
            }
        } else {
            // Regular search validation
            return !fromIataCode.isEmpty && !toIataCode.isEmpty && !selectedDates.isEmpty
        }
    }
}
