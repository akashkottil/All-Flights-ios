import SwiftUICore
import CoreLocation
import Combine
import Foundation
import SwiftUI


class CurrentLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = CurrentLocationManager()
    
    @Published var locationState: LocationState = .idle
    @Published var currentLocation: CLLocation?
    @Published var locationName: String = ""
    @Published var nearestAirportCode: String = ""
    
    private let locationManager = CLLocationManager()
    private var completion: ((Result<LocationResult, LocationError>) -> Void)?
    // FIX 1: Make cancellables mutable
    private var cancellables = Set<AnyCancellable>()
    
    // FIX 2: Make LocationState conform to Equatable
    enum LocationState: Equatable {
        case idle
        case requesting
        case locating
        case geocoding
        case success
        case error(LocationError)
        
        // Add Equatable conformance
        static func == (lhs: LocationState, rhs: LocationState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.requesting, .requesting), (.locating, .locating), (.geocoding, .geocoding), (.success, .success):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    enum LocationError: LocalizedError {
        case permissionDenied
        case locationUnavailable
        case geocodingFailed
        case airportNotFound
        case timeout
        
        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Location access denied. Please enable in Settings."
            case .locationUnavailable:
                return "Unable to get your location. Please try again."
            case .geocodingFailed:
                return "Unable to determine your location."
            case .airportNotFound:
                return "No nearby airports found."
            case .timeout:
                return "Location request timed out. Please try again."
            }
        }
    }
    
    struct LocationResult {
        let locationName: String
        let airportCode: String
        let coordinates: CLLocationCoordinate2D
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100
    }
    
    func getCurrentLocation(completion: @escaping (Result<LocationResult, LocationError>) -> Void) {
        self.completion = completion
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationState = .requesting
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            locationState = .error(.permissionDenied)
            completion(.failure(.permissionDenied))
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdate()
        @unknown default:
            locationState = .error(.locationUnavailable)
            completion(.failure(.locationUnavailable))
        }
    }
    
    private func startLocationUpdate() {
        guard CLLocationManager.locationServicesEnabled() else {
            locationState = .error(.locationUnavailable)
            completion?(.failure(.locationUnavailable))
            return
        }
        
        locationState = .locating
        locationManager.requestLocation()
        
        // Set timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if case .locating = self.locationState {
                self.locationState = .error(.timeout)
                self.completion?(.failure(.timeout))
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        currentLocation = location
        locationState = .geocoding
        
        // Reverse geocode to get location name
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("Geocoding error: \(error)")
                    self.locationState = .error(.geocodingFailed)
                    self.completion?(.failure(.geocodingFailed))
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    self.locationState = .error(.geocodingFailed)
                    self.completion?(.failure(.geocodingFailed))
                    return
                }
                
                // Create location name
                let locationName = self.createLocationName(from: placemark)
                self.locationName = locationName
                
                // Find nearest airport
                self.findNearestAirport(to: location.coordinate) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let airportCode):
                            self.nearestAirportCode = airportCode
                            self.locationState = .success
                            
                            let locationResult = LocationResult(
                                locationName: locationName,
                                airportCode: airportCode,
                                coordinates: location.coordinate
                            )
                            self.completion?(.success(locationResult))
                            
                        case .failure(let error):
                            self.locationState = .error(error)
                            self.completion?(.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationState = .error(.locationUnavailable)
            self.completion?(.failure(.locationUnavailable))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if case .requesting = locationState {
                startLocationUpdate()
            }
        case .denied, .restricted:
            locationState = .error(.permissionDenied)
            completion?(.failure(.permissionDenied))
        default:
            break
        }
    }
    
    // MARK: - Helper Methods
    
    private func createLocationName(from placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        if let locality = placemark.locality {
            components.append(locality)
        } else if let subAdministrativeArea = placemark.subAdministrativeArea {
            components.append(subAdministrativeArea)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        
        if let country = placemark.country {
            components.append(country)
        }
        
        return components.isEmpty ? "Current Location" : components.joined(separator: ", ")
    }
    
    private func findNearestAirport(to coordinate: CLLocationCoordinate2D, completion: @escaping (Result<String, LocationError>) -> Void) {
        // Use the existing autocomplete API to find airports near the location
        let searchQuery = "\(locationName.components(separatedBy: ",").first ?? "airport")"
        
        ExploreAPIService.shared.fetchAutocomplete(query: searchQuery)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure = result {
                        completion(.failure(.airportNotFound))
                    }
                },
                receiveValue: { airports in
                    // Find the closest airport
                    let currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    
                    var closestAirport: AutocompleteResult?
                    var closestDistance: Double = Double.infinity
                    
                    for airport in airports.filter({ $0.type == "airport" }) {
                        if let lat = Double(airport.coordinates.latitude),
                           let lon = Double(airport.coordinates.longitude) {
                            let airportLocation = CLLocation(latitude: lat, longitude: lon)
                            let distance = currentLocation.distance(from: airportLocation)
                            
                            if distance < closestDistance {
                                closestDistance = distance
                                closestAirport = airport
                            }
                        }
                    }
                    
                    if let airport = closestAirport {
                        completion(.success(airport.iataCode))
                    } else {
                        // Fallback to city search if no airports found
                        if let cityAirport = airports.first(where: { $0.type == "city" }) {
                            completion(.success(cityAirport.iataCode))
                        } else {
                            completion(.failure(.airportNotFound))
                        }
                    }
                }
            )
            .store(in: &cancellables) // FIX 3: Now cancellables is mutable
    }
}

// MARK: - Enhanced Current Location Button (Fixed)
struct EnhancedCurrentLocationButton: View {
    @StateObject private var locationManager = CurrentLocationManager.shared
    @State private var isAnimating = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var iconRotation: Double = 0
    @State private var showError = false
    @State private var errorMessage = ""
    
    let onLocationSelected: (CurrentLocationManager.LocationResult) -> Void
    
    var body: some View {
        Button(action: handleLocationRequest) {
            HStack(spacing: 12) {
                ZStack {
                    if case .locating = locationManager.locationState {
                        // Animated location icon
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                            .opacity(isAnimating ? 0.7 : 1.0)
                            .animation(
                                .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    } else if case .geocoding = locationManager.locationState {
                        // Spinning icon for geocoding
                        Image(systemName: "location.magnifyingglass")
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(iconRotation))
                            .animation(
                                .linear(duration: 1.0).repeatForever(autoreverses: false),
                                value: iconRotation
                            )
                    } else if case .requesting = locationManager.locationState {
                        // Permission requesting state
                        Image(systemName: "location.circle")
                            .foregroundColor(.orange)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(
                                .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    } else {
                        // Default state
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                    }
                }
                .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(getLocationButtonText())
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        
                        // FIX 4: Simplified condition check
                        if isLocationLoading {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        }
                    }
                    
                    if case .geocoding = locationManager.locationState {
                        Text("Finding nearest airport...")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(getBackgroundColor().opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(getBackgroundColor().opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(buttonScale)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: buttonScale)
        }
        .disabled(isLocationLoading)
        .alert("Location Error", isPresented: $showError) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: locationManager.locationState) { _, newState in // FIX 5: Updated onChange syntax
            handleLocationStateChange(newState)
        }
    }
    
    private var isLocationLoading: Bool {
        switch locationManager.locationState {
        case .requesting, .locating, .geocoding:
            return true
        default:
            return false
        }
    }
    
    private func getLocationButtonText() -> String {
        switch locationManager.locationState {
        case .idle:
            return "Use Current Location"
        case .requesting:
            return "Requesting Permission..."
        case .locating:
            return "Getting Your Location..."
        case .geocoding:
            return "Processing Location..."
        case .success:
            return "Location Found!"
        case .error:
            return "Try Again"
        }
    }
    
    private func getBackgroundColor() -> Color {
        switch locationManager.locationState {
        case .requesting:
            return .orange
        case .locating, .geocoding:
            return .blue
        case .success:
            return .green
        case .error:
            return .red
        default:
            return .blue
        }
    }
    
    private func handleLocationRequest() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Button press animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            buttonScale = 0.95
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                buttonScale = 1.0
            }
        }
        
        // Start location request
        locationManager.getCurrentLocation { result in
            switch result {
            case .success(let locationResult):
                // Success animation
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    buttonScale = 1.05
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        buttonScale = 1.0
                    }
                    onLocationSelected(locationResult)
                }
                
            case .failure(let error):
                // Error handling
                errorMessage = error.localizedDescription
                showError = true
                
                // Error animation
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    buttonScale = 0.95
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        buttonScale = 1.0
                    }
                }
            }
        }
    }
    
    private func handleLocationStateChange(_ newState: CurrentLocationManager.LocationState) {
        switch newState {
        case .locating:
            isAnimating = true
        case .geocoding:
            iconRotation = 360
        case .requesting:
            isAnimating = true
        case .success, .error, .idle:
            isAnimating = false
            iconRotation = 0
        }
    }
}




// MARK: - Enhanced Search Input Component (exact UI match)
struct EnhancedSearchInput: View {
    @State private var swapButtonScale: CGFloat = 1.0
    @State private var searchButtonScale: CGFloat = 1.0
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    @State private var showingFromLocationSheet = false
    @State private var showingToLocationSheet = false
    @State private var showingCalendar = false
    @State private var showingPassengersSheet = false

    @State private var editingTripIndex = 0
    @State private var editingFromOrTo: LocationType = .from
    
    // ENHANCED: Animation states for location swap
    @State private var swapRotationDegrees: Double = 0
    @State private var fromLocationOffset: CGFloat = 0
    @State private var toLocationOffset: CGFloat = 0
    @State private var fromLocationOpacity: Double = 1.0
    @State private var toLocationOpacity: Double = 1.0
    @State private var fromLocationScale: CGFloat = 1.0
    @State private var toLocationScale: CGFloat = 1.0
    @State private var isSwapping: Bool = false
    
    @State private var showErrorMessage = false
    
    @State private var showDirectFlightsToggle = true
    
    // Animation namespace for matched geometry effects
       @Namespace private var tripAnimation
    
    @State private var searchInputScale: CGFloat = 1.0
    @State private var searchInputOffset: CGFloat = 0
    
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
        // Since we now always ensure dates exist, this logic is simplified
        if searchViewModel.selectedDates.count == 1 {
            // One-way trip: Show the selected departure date
            return formatDateForDisplay(searchViewModel.selectedDates[0])
        } else if searchViewModel.selectedDates.count >= 2 {
            // Round trip: Show both selected dates
            let sortedDates = searchViewModel.selectedDates.sorted()
            return "\(formatDateForDisplay(sortedDates[0])) - \(formatDateForDisplay(sortedDates[1]))"
        } else {
            // Fallback (should rarely happen now due to default date setting)
            let formatter = DateFormatter()
            formatter.dateFormat = "E, d MMM"
            
            if searchViewModel.isRoundTrip {
                let today = Date()
                let calendar = Calendar.current
                let departureDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
                let returnDate = calendar.date(byAdding: .day, value: 8, to: today) ?? today
                return "\(formatter.string(from: departureDate)) - \(formatter.string(from: returnDate))"
            } else {
                let today = Date()
                let calendar = Calendar.current
                let departureDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
                return formatter.string(from: departureDate)
            }
        }
    }

    private func getDateTextColor() -> Color {
        // Since we always have dates now, always return primary color
        return .primary
    }
    
    // MARK: - Native Contained Swap Animation
    private func animatedSwapLocations() {
        // Prevent multiple swaps during animation
        guard !isSwapping else { return }
        
        // Set swapping state
        isSwapping = true
        
        // Native iOS haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Phase 1: Button scale with native spring (0.0-0.2s)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            swapButtonScale = 1.1
        }
        
        // Phase 2: Locations move towards center (0.1-0.4s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                // Both locations move slightly towards the center
                fromLocationOffset = 25    // FROM moves down 25px
                toLocationOffset = -25     // TO moves up 25px
                fromLocationOpacity = 0.7
                toLocationOpacity = 0.7
                fromLocationScale = 0.95
                toLocationScale = 0.95
            }
        }
        
        // Phase 3: Button rotation (0.2-0.6s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                swapRotationDegrees += 180  // Half rotation for subtlety
            }
        }
        
        // Phase 4: Data swap at the meeting point (0.35s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            // Perform the location swap
            let tempLocation = searchViewModel.fromLocation
            let tempCode = searchViewModel.fromIataCode
            
            searchViewModel.fromLocation = searchViewModel.toLocation
            searchViewModel.fromIataCode = searchViewModel.toIataCode
            
            searchViewModel.toLocation = tempLocation
            searchViewModel.toIataCode = tempCode
        }
        
        // Phase 5: Locations cross and settle (0.4-0.7s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                // Complete the crossing motion
                fromLocationOffset = 0     // FROM (now swapped) settles to TO position
                toLocationOffset = 0       // TO (now swapped) settles to FROM position
                fromLocationOpacity = 1.0
                toLocationOpacity = 1.0
                fromLocationScale = 1.02   // Slight emphasis
                toLocationScale = 1.02
            }
        }
        
        // Phase 6: Button returns to normal (0.5-0.7s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                swapButtonScale = 1.0
                swapRotationDegrees += 180  // Complete full rotation
            }
        }
        
        // Phase 7: Final scale normalization (0.6-0.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                fromLocationScale = 1.0
                toLocationScale = 1.0
            }
        }
        
        // Phase 8: Complete animation (0.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isSwapping = false
            
            // Native selection haptic
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
        }
    }

       
    // MARK: - Updated performSearch method in EnhancedSearchInput
    private func performSearch() {
        // MODIFIED: Ensure we always have dates by setting defaults if empty
        if searchViewModel.selectedDates.isEmpty {
            let today = Date()
            let calendar = Calendar.current
            
            if searchViewModel.isRoundTrip {
                // For round trip: Use tomorrow as departure and tomorrow + 7 days as return
                let departureDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
                let returnDate = calendar.date(byAdding: .day, value: 8, to: today) ?? today
                searchViewModel.selectedDates = [departureDate, returnDate]
            } else {
                // For one-way: Use tomorrow as departure
                let departureDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
                searchViewModel.selectedDates = [departureDate]
            }
        }
        
        // NEW: Check for "anytime" or "anywhere" conditions
        _ = searchViewModel.selectedDates.isEmpty // This should now be false due to above logic
        let isAnywhereSearch = searchViewModel.toLocation == "Anywhere" || searchViewModel.toLocation == "Destination?" || searchViewModel.toIataCode.isEmpty
        
        // If anywhere is selected, navigate to explore screen instead
        if isAnywhereSearch {
            // Clear any search state and navigate to explore mode
            SharedSearchDataStore.shared.isInSearchMode = false
            SharedSearchDataStore.shared.shouldNavigateToTab = 2 // Navigate to explore tab (index 1)
            
            // Clear search execution flags
            SharedSearchDataStore.shared.shouldExecuteSearch = false
            SharedSearchDataStore.shared.shouldNavigateToExplore = false
            
            return
        }
        
        // Updated validation for required fields (dates are now guaranteed to exist)
        let valid: Bool
        if searchViewModel.selectedTab == 2 {
            valid = searchViewModel.multiCityTrips.allSatisfy { trip in
                !trip.fromIataCode.isEmpty && !trip.toIataCode.isEmpty
            }
        } else {
            valid = !searchViewModel.fromIataCode.isEmpty && !searchViewModel.toIataCode.isEmpty
            // Removed selectedDates.isEmpty check since we now ensure default dates exist
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
                .stroke(Color.orange, lineWidth: 2)
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
    
    
    // MARK: - Updated Trip Type Tabs in EnhancedSearchInput
    private var tripTypeTabs: some View {
        let titles = ["Return", "One way", "Multi city"]
        let totalWidth = UIScreen.main.bounds.width * 0.65
        let tabWidth = totalWidth / 3
        let padding: CGFloat = 6 // Consistent padding for all sides
        
        return ZStack(alignment: .leading) {
            // Background capsule (gray background, height remains the same)
            Capsule()
                .fill(Color(UIColor.systemGray6))
                .frame(height: 44)  // Keep the gray background height at 44
                
            // Sliding white background for selected tab (height slightly increased)
            Capsule()
                .fill(Color.white)
                .frame(width: tabWidth - (padding * 2), height: 34)  // Slightly increased height of the white background
                .offset(x: (CGFloat(searchViewModel.selectedTab) * tabWidth) + padding)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: searchViewModel.selectedTab)
            
            // Tab buttons
            HStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    Button(action: {
                        // MODIFIED: Use the new updateTripType method that handles dates
                        if index == 2 {
                            searchViewModel.updateTripType(newTab: index, newIsRoundTrip: searchViewModel.isRoundTrip)
                            searchViewModel.initializeMultiCityTrips()
                        } else {
                            let newIsRoundTrip = (index == 0)
                            searchViewModel.updateTripType(newTab: index, newIsRoundTrip: newIsRoundTrip)
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



    // MARK: - Fixed Multi-City Interface with Always Visible Add Flight Button
    private var updatedMultiCityInterface: some View {
        VStack(spacing: 16) {
            // Flight segments with enhanced animations
            VStack(spacing: 8) {
                ForEach(searchViewModel.multiCityTrips.indices, id: \.self) { index in
                    HomeMultiCitySegmentView(
                        searchViewModel: searchViewModel,
                        trip: searchViewModel.multiCityTrips[index],
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
                            Image("cardpassenger")
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

                    // FIXED: Always show vertical divider and add flight button when under limit
                    if searchViewModel.multiCityTrips.count < 4 {
                        Rectangle()
                            .frame(width: 1)
                            .foregroundColor(Color.gray.opacity(0.3))
                            .frame(maxHeight: .infinity)

                        Spacer()

                        // FIXED: Always show Add Flight button, but disable when needed
                        Button(action: addTrip) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .foregroundColor(canAddTrip ? .blue : .gray)
                                    .font(.system(size: 16, weight: .semibold))

                                Text("Add flight")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(canAddTrip ? .blue : .gray)
                            }
                            .padding(.vertical, 16)
                            .padding(.trailing, 12)
                        }
                        .disabled(!canAddTrip)
                        .frame(maxHeight: .infinity)
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
        VStack(spacing: 5) {
            // ENHANCED: From location button with animation
            fromLocationButton
                .offset(y: fromLocationOffset)
                .opacity(fromLocationOpacity)
                .scaleEffect(fromLocationScale)
                .animation(.easeInOut(duration: 0.3), value: fromLocationOffset)
                .animation(.easeInOut(duration: 0.25), value: fromLocationOpacity)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: fromLocationScale)
                
            ZStack {
                Divider()
                    .padding(.leading,40)
                    .padding(.trailing,-20)
                    .padding(.vertical,1)
                
                // ENHANCED: Swap button with improved animations
                enhancedSwapButton
            }
            
            // ENHANCED: To location button with animation
            toLocationButton
                .offset(y: toLocationOffset)
                .opacity(toLocationOpacity)
                .scaleEffect(toLocationScale)
                .animation(.easeInOut(duration: 0.3), value: toLocationOffset)
                .animation(.easeInOut(duration: 0.25), value: toLocationOpacity)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toLocationScale)
                
            Divider()
                .padding(.leading,40)
                .padding(.trailing,-20)
                .padding(.vertical,6)
            dateButton
                .padding(.vertical,4)
            Divider()
                .padding(.leading,40)
                .padding(.trailing,-20)
                .padding(.vertical,6)
            passengerButton
                .padding(.bottom,4)
           
            searchButton
            directFlightsToggle
                .padding(.top,4)
        }
    }
    
    private var fromLocationButton: some View {
        Button(action: {
            showingFromLocationSheet = true
        }) {
            HStack(spacing: 12) {
                Image("carddeparture")
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
            .padding(.top, 8)
            .padding(.horizontal, 12)
        }
    }
    
    // ENHANCED: New swap button component
    private var enhancedSwapButton: some View {
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
                        .scaleEffect(swapButtonScale)
                    
                    Image("swap")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(isSwapping ? Color.blue.opacity(0.8) : Color.blue)
                        .rotationEffect(.degrees(swapRotationDegrees))
                        .scaleEffect(isSwapping ? 1.1 : 1.0)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 15), value: swapRotationDegrees)
                        .animation(.easeInOut(duration: 0.2), value: isSwapping)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isSwapping) // Prevent multiple taps during animation
        }
        .padding(.horizontal)
    }

    
    private var toLocationButton: some View {
        Button(action: {
            showingToLocationSheet = true
        }) {
            HStack(spacing: 12) {
                Image("carddestination")
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
                Image("cardcalendar")
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
                Image("cardpassenger")
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
            Button(action: {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                // Button press animation
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    searchButtonScale = 0.96
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        searchButtonScale = 1.0
                    }
                }
                
                performSearch()
            }) {
                Text("Search Flights")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color("buttonColor"))
                    .cornerRadius(14)
                    .scaleEffect(searchButtonScale)
            }

            if showErrorMessage {
                Label("Select location to search flight",systemImage: "exclamationmark.triangle")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private var directFlightsToggle: some View {
        HStack(spacing: 8) {
            Text("Direct flights only")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)

            Toggle("", isOn: $searchViewModel.directFlightsOnly)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .labelsHidden() // Hide the label of the toggle itself
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .leading) // Align left
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
            return "Anytime"  // Changed from "Select dates"
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


// MARK: - Fixed Home Multi-City Segment View
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
                Button(action: onFromTap) {
                    HStack( spacing: 2) {
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
                    .padding(.top, 10)
                
                // To Location Column
                Button(action: onToTap) {
                    HStack( spacing: 2) {
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
                    .padding(.top, 10)
                
                // Date Column
                Button(action: onDateTap) {
                    Text(trip.compactDisplayDate)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: 100, alignment: .leading)
                }
                
                // FIXED: Only show the right divider when there's a delete button
                if canRemove {
                    Divider()
                        .frame(width: 1, height: 76)
                        .background(Color.gray.opacity(0.3))
                        .padding(.top, 10)
                    
                    // Remove Button Column - only when canRemove is true
                    Button(action: onRemove) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                    }
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
                // UPDATED: Pass appropriate search type based on isFromLocation
                RecentLocationSearchView(
                    onLocationSelected: { result in
                        selectLocation(result: result)
                    },
                    showAnywhereOption: false,
                    searchType: isFromLocation ? .departure : .destination
                )
                Spacer()
            }else if shouldShowNoResults() {
                Text("No results found")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                // UPDATED: Pass appropriate search type based on isFromLocation
                RecentLocationSearchView(
                    onLocationSelected: { result in
                        selectLocation(result: result)
                    },
                    showAnywhereOption: false,
                    searchType: isFromLocation ? .departure : .destination
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
        let searchType: LocationSearchType = isFromLocation ? .departure : .destination
               recentSearchManager.addRecentSearch(result, searchType: searchType)
        
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
                    // Date display (always show, will display "Anytime" when no dates selected)
                    Text(formatDatesForCollapsed())
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer()

                    
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
                    .stroke(Color.orange, lineWidth: 2)
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
        return "Anytime"  // Changed from "Select dates"
    }

    // UPDATED: formatDatesForCollapsed with new format
    private func formatDatesForCollapsed() -> String {
        if searchViewModel.selectedDates.count >= 2 {
            let sortedDates = searchViewModel.selectedDates.sorted()
            let startDate = sortedDates[0]
            let endDate = sortedDates[1]
            
            let calendar = Calendar.current
            let startMonth = calendar.component(.month, from: startDate)
            let endMonth = calendar.component(.month, from: endDate)
            let startYear = calendar.component(.year, from: startDate)
            let endYear = calendar.component(.year, from: endDate)
            
            if startMonth == endMonth && startYear == endYear {
                // Same month: "Jun 15-22"
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "MMM"
                let month = monthFormatter.string(from: startDate)
                
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "d"
                let startDay = dayFormatter.string(from: startDate)
                let endDay = dayFormatter.string(from: endDate)
                
                return "\(month) \(startDay)-\(endDay)"
            } else {
                // Different months: "Jun 15-Jul 22"
                let startFormatter = DateFormatter()
                startFormatter.dateFormat = "MMM d"
                let startFormatted = startFormatter.string(from: startDate)
                
                let endFormatter = DateFormatter()
                endFormatter.dateFormat = "MMM d"
                let endFormatted = endFormatter.string(from: endDate)
                
                return "\(startFormatted)-\(endFormatted)"
            }
        } else if searchViewModel.selectedDates.count == 1 {
            // Single date: "Jun 15"
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: searchViewModel.selectedDates[0])
        } else {
            // No dates: "Anytime"
            return "Anytime"
        }
    }
}




// MARK: - Updated Home Location Search Sheets with Recent Searches

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
            // Enhanced Current Location Button
            EnhancedCurrentLocationButton { locationResult in
                // Handle successful location selection with animation
                withAnimation(.easeInOut(duration: 0.3)) {
                    searchViewModel.fromLocation = locationResult.locationName
                    searchViewModel.fromIataCode = locationResult.airportCode
                    searchText = locationResult.locationName
                }
                
                // Add to recent searches
                let autocompleteResult = AutocompleteResult(
                    iataCode: locationResult.airportCode,
                    airportName: "Current Location",
                    type: "airport",
                    displayName: locationResult.locationName,
                    cityName: locationResult.locationName.components(separatedBy: ",").first ?? "",
                    countryName: locationResult.locationName.components(separatedBy: ",").last ?? "",
                    countryCode: "IN",
                    imageUrl: "",
                    coordinates: AutocompleteCoordinates(
                        latitude: String(locationResult.coordinates.latitude),
                        longitude: String(locationResult.coordinates.longitude)
                    )
                )
                
                recentSearchManager.addRecentSearch(autocompleteResult, searchType: .departure)
                
                // Dismiss with a slight delay for better UX
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
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
                // Show recent searches when no active search - UPDATED: Filter for departure
                RecentLocationSearchView(
                    onLocationSelected: { result in
                        selectLocation(result: result)
                    },
                    showAnywhereOption: false,
                    searchType: .departure  // ADD: Filter for departure searches only
                )
                Spacer()
            }  else if shouldShowNoResults() {
                Text("No results found")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            }else {
                // UPDATED: Filter for departure searches only
                RecentLocationSearchView(
                    onLocationSelected: { result in
                        selectLocation(result: result)
                    },
                    showAnywhereOption: false,
                    searchType: .departure  // ADD: Filter for departure searches only
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
        recentSearchManager.addRecentSearch(result, searchType: .departure)
        
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
            
            // Results section with recent searches (NO ANYWHERE OPTION)
            if isSearching {
                VStack {
                    ProgressView()
                    Text("Searching...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                Spacer()
            } else if !results.isEmpty {
                // Show search results with Anywhere option at top
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // ADDED: Anywhere option at top of search results
                        AnywhereOptionRow()
                            .onTapGesture {
                                selectAnywhereLocation()
                            }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        ForEach(results) { result in
                            LocationResultRow(result: result)
                                .onTapGesture {
                                    selectLocation(result: result)
                                }
                        }
                    }
                }
            } else if showRecentSearches && searchText.isEmpty {
                // Show recent searches with Anywhere option at top
                VStack(spacing: 0) {
                    // ADDED: Anywhere option at top of recent searches
                    AnywhereOptionRow()
                        .onTapGesture {
                            selectAnywhereLocation()
                        }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    RecentLocationSearchView(
                        onLocationSelected: { result in
                            selectLocation(result: result)
                        },
                        showAnywhereOption: false,
                        searchType: .destination
                    )
                }
                Spacer()
            } else if shouldShowNoResults() {
                Text("No results found")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                // Default state with Anywhere option
                VStack(spacing: 0) {
                    AnywhereOptionRow()
                        .onTapGesture {
                            selectAnywhereLocation()
                        }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    RecentLocationSearchView(
                        onLocationSelected: { result in
                            selectLocation(result: result)
                        },
                        showAnywhereOption: false,
                        searchType: .destination
                    )
                }
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
    
    private func selectAnywhereLocation() {
        searchViewModel.toLocation = "Anywhere"
        searchViewModel.toIataCode = ""
        dismiss()
    }
    
    private func shouldShowNoResults() -> Bool {
        return results.isEmpty && !searchText.isEmpty && !showRecentSearches
    }
    
    private func selectLocation(result: AutocompleteResult) {
        // IMPORTANT: Add to recent searches before processing
        recentSearchManager.addRecentSearch(result, searchType: .destination)
        
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
                // Clear the selected dates when anytime is selected
                searchViewModel.selectedDates = []
                dismiss()
            },
            onTripTypeChange: { newIsRoundTrip in
                searchViewModel.isRoundTrip = newIsRoundTrip
                searchViewModel.selectedTab = newIsRoundTrip ? 1 : 0
            }
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




