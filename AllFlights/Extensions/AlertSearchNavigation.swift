import SwiftUI
import Foundation

// MARK: - Alert Search Navigation Extension
extension SharedSearchDataStore {
    
    /// Navigate from Alert to Explore with pre-filled data
    func executeSearchFromAlert(
        fromLocationCode: String,
        fromLocationName: String,
        toLocationCode: String,
        toLocationName: String,
        departureDate: Date,
        adultsCount: Int,
        childrenCount: Int,
        selectedCabinClass: String
    ) {
        // Clear any existing search state
        self.resetAll()
        
        // Set search parameters from alert
        self.fromLocation = fromLocationName
        self.toLocation = toLocationName
        self.fromIataCode = fromLocationCode
        self.toIataCode = toLocationCode
        self.selectedDates = [departureDate]
        self.isRoundTrip = false // Default to one-way for alerts
        self.selectedTab = 1 // One-way tab
        self.adultsCount = adultsCount
        self.childrenCount = childrenCount
        self.selectedCabinClass = selectedCabinClass
        self.directFlightsOnly = false
        
        // Set navigation flags
        self.isInSearchMode = true
        self.isDirectFromHome = true
        self.shouldExecuteSearch = true
        self.shouldNavigateToExplore = true
        self.searchTimestamp = Date()
        
        print("🚨 Alert Search: Navigating to explore with \(fromLocationName) → \(toLocationName)")
    }
}
