import SwiftUICore
import Combine
import SwiftUI
import SafariServices

// MARK: - Expanded Search Card Component (UPDATED with drag gesture)
struct ExpandedSearchCard: View {
    @ObservedObject var viewModel: ExploreViewModel
    @Binding var selectedTab: Int
    @Binding var isRoundTrip: Bool
    let searchCardNamespace: Namespace.ID
    let handleBackNavigation: () -> Void
    let shouldShowBackButton: Bool
    let onDragCollapse: () -> Void
    
    @GestureState private var dragOffset: CGFloat = 0
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                if value.translation.height < -20 {
                    onDragCollapse()
                }
            }
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                // FIXED: Use ZStack for proper centering
                ZStack {
                    // Centered trip type tabs - always perfectly centered
                    TripTypeTabView(selectedTab: $selectedTab, isRoundTrip: $isRoundTrip, viewModel: viewModel)
                        .matchedGeometryEffect(id: "tripTabs", in: searchCardNamespace)
                    
                    // Back button positioned absolutely on the left
                    HStack {
                        if shouldShowBackButton {
                            Button(action: handleBackNavigation) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .matchedGeometryEffect(id: "backButton", in: searchCardNamespace)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 15)
                
                // Search card with dynamic values
                SearchCard(viewModel: viewModel, isRoundTrip: $isRoundTrip, selectedTab: selectedTab)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .matchedGeometryEffect(id: "searchContent", in: searchCardNamespace)
            }
            .background(
                ZStack {
                    // Background fill
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .matchedGeometryEffect(id: "cardBackground", in: searchCardNamespace)
                    
                    // Animated or static stroke based on loading state
                    if viewModel.isLoading ||
                       viewModel.isLoadingFlights ||
                       viewModel.isLoadingDetailedFlights ||
                       (viewModel.showingDetailedFlightList && viewModel.detailedFlightResults.isEmpty && viewModel.detailedFlightError == nil) {
                        LoadingBorderView()
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange, lineWidth: 2)
                    }
                }
                // FIXED: Move shadow to only the background/border
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            )
            .padding()
            .gesture(dragGesture)
        }
        .background(
            GeometryReader { geo in
                VStack(spacing: 0) {
                    Color("searchcardBackground")
                        .frame(height: geo.size.height)
                    Color("scroll")
                }
                .edgesIgnoringSafeArea(.all)
            }
        )
    }
}

// MARK: - Collapsed Search Card Component (with passenger count)

struct CollapsedSearchCard: View {
    @ObservedObject var viewModel: ExploreViewModel
    let searchCardNamespace: Namespace.ID
    let onTap: () -> Void
    let handleBackNavigation: () -> Void
    let shouldShowBackButton: Bool
    
    // Helper method to format date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    // UPDATED: Better display logic for collapsed state
    private func getLocationDisplayText() -> String {
        let fromText = viewModel.fromLocation.isEmpty || viewModel.fromLocation == "Mumbai" ? "From" : viewModel.fromLocation
        let toText = viewModel.toLocation == "Anywhere" || viewModel.toLocation.isEmpty ? "Anywhere" : viewModel.toLocation
        return "\(fromText) → \(toText)"
    }
    
    private func getDateDisplayText() -> String {
        // If we just cleared the form, show "Anytime"
        if viewModel.dates.isEmpty && viewModel.selectedDepartureDatee.isEmpty {
            return "Anytime"
        }
        
        if viewModel.dates.isEmpty && viewModel.hasSearchedFlights && !viewModel.flightResults.isEmpty {
            return "Anytime"
        } else if viewModel.dates.isEmpty {
            return "Anytime"
        } else if viewModel.dates.count == 1 {
            return formatDate(viewModel.dates[0])
        } else if viewModel.dates.count >= 2 {
            return "\(formatDate(viewModel.dates[0])) - \(formatDate(viewModel.dates[1]))"
        }
        return "Anytime"
    }
    
    // ADD: Passenger display text for collapsed state
    private func getPassengerDisplayText() -> String {
        let totalPassengers = viewModel.adultsCount + viewModel.childrenCount
        return "\(totalPassengers)"
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack {
                    // Back button
                    if shouldShowBackButton{
                        Button(action: handleBackNavigation) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .matchedGeometryEffect(id: "backButton", in: searchCardNamespace)
                    }
                    
                    Spacer()
                    
                    // Compact trip info - UPDATED with passenger count
                    HStack(spacing: 8) {
                        Text(getLocationDisplayText())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                        
                        // Date display
                        Text(getDateDisplayText())
                            .foregroundColor(.primary)
                            .font(.system(size: 14, weight: .medium))
                        
                        // ADD: Passenger count after date
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                        
                        HStack {
                            Image("cardpassenger")
                                .foregroundColor(.black)
                            Text(getPassengerDisplayText())
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .matchedGeometryEffect(id: "searchContent", in: searchCardNamespace)
                    
                    Spacer()
                    
                    // ADD: Invisible spacer to balance layout when back button is hidden
                    if !shouldShowBackButton {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.clear)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .padding(.top, 5)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .matchedGeometryEffect(id: "cardBackground", in: searchCardNamespace)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange, lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
        // UPDATED: Add the same animated background as ExpandedSearchCard
        .background(
            GeometryReader { geo in
                VStack(spacing: 0) {
                    Color("searchcardBackground")
                        .frame(height: geo.size.height)
                    Color("scroll")
                }
                .edgesIgnoringSafeArea(.all)
            }
        )
    }
}

// MARK: - Custom ScrollView with Offset Detection
struct ScrollViewWithOffset<Content: View>: View {
    @Binding var offset: CGFloat
    let content: () -> Content
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self,
                              value: geometry.frame(in: .named("scrollView")).minY)
            }
            .frame(height: 0)
            
            content()
        }
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            offset = -value
        }
    }
}

// MARK: - Preference Key for Scroll Offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}




// MARK: - Search Card Component (Updated with Conditional Multi-City)
struct SearchCard: View {
    @ObservedObject var viewModel: ExploreViewModel
    @State private var showingSearchSheet = false
    @State private var initialFocus: LocationSearchSheet.SearchBarType = .origin
    @State private var showingCalendar = false
    
    // ADD: State for swap animation
    @State private var swapRotationDegrees: Double = 0
    
    @Binding var isRoundTrip: Bool
    
    var selectedTab: Int
    
    // ADD: Observe shared search data
    @StateObject private var sharedSearchData = SharedSearchDataStore.shared
    
    // Determine if multi-city should be shown
    private var shouldShowMultiCity: Bool {
        return sharedSearchData.isInSearchMode && sharedSearchData.selectedTab == 2 && selectedTab == 2
    }
    
    var body: some View {
            // Conditionally show multi-city or regular interface
            if shouldShowMultiCity {
                // Multi-city search card - only show when came from direct multi-city search
                MultiCitySearchCard(viewModel: viewModel)
            } else {
                // Regular interface for return/one-way trips
                ZStack {
                    // Extended vertical line that goes behind everything except the swap button
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: 88)
                        .offset(y: 5)
                        .zIndex(0) // Ensure it's behind other content
                    
                    VStack(alignment:.leading,spacing: 5) {
                        Divider()
                            .padding(.horizontal,-16)
                        
                        // From row with fixed swap button position
                        ZStack {
                            HStack {
                                // From button - takes available space on left
                                Button(action: {
                                    initialFocus = .origin
                                    showingSearchSheet = true
                                }) {
                                    HStack {
                                        Image("carddeparture")
                                            .foregroundColor(.primary)
                                        Text(getFromLocationDisplayText())
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(getFromLocationTextColor())
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .zIndex(1) // Above the line
                                
                              
                                
                                
                                // To button - takes available space on right
                                Button(action: {
                                    initialFocus = .destination
                                    showingSearchSheet = true
                                }) {
                                    HStack {
                                        Image("carddestination")
                                            .foregroundColor(.primary)
                                        
                                        Text(getToLocationDisplayText())
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(getToLocationTextColor())
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.leading, 16)
                                   
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .zIndex(1) // Above the line
                            }
                            
                            // Swap button - absolutely centered
                            Button(action: {
                                animatedSwapLocations()
                            }) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                        .frame(width: 26, height: 26)
                                        .background(Circle().fill(Color.white)) // White background to cover the line
                                    Image("swapexplore")
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                        .font(.system(size: 14))
                                        .rotationEffect(.degrees(swapRotationDegrees))
                                        .animation(.easeInOut(duration: 0.6), value: swapRotationDegrees)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .zIndex(2) // Above everything else
                        }
                        .padding(4)
                        
                        Divider()
                            .padding(.horizontal,-16)
                        
                        
                        // Date and passengers row - FIXED VERSION
                        HStack {
                            // Date button - flexible width with proper constraints
                            Button(action: {
                                // Only show calendar if destination is not "Anywhere"
                                if viewModel.toLocation == "Anywhere" {
                                    handleAnywhereDestination()
                                } else {
                                    showingCalendar = true
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image("cardcalendar")
                                        .foregroundColor(.primary)
                                    
                                    Text(getDateDisplayText())
                                        .foregroundColor(getDateTextColor())
                                        .font(.system(size: 14, weight: .medium))
                                        .lineLimit(1) // Force single line
                                        .minimumScaleFactor(0.8) // Allow text to scale down slightly if needed
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading) // Take available space
                            .zIndex(1) // Above the line
                            
                            // Passenger selection button - fixed width from the right
                            Button(action: {
                                viewModel.showingPassengersSheet = true
                            }) {
                                HStack(spacing: 4) {
                                    Image("cardpassenger")
                                        .foregroundColor(.black)
                                    
                                    Text("\(viewModel.adultsCount + viewModel.childrenCount), \(viewModel.selectedCabinClass)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                }
                                .padding(.trailing,56)
                            }
                            // Align to right side
                            .zIndex(1) // Above the line
                        }
                        .padding(.vertical, 4)
                      
                    }
                    .zIndex(1) // Ensure VStack content is above the background line
                }
                .sheet(isPresented: $showingSearchSheet) {
                    LocationSearchSheet(viewModel: viewModel, initialFocus: initialFocus)
                        .presentationDetents([.large])
                }
                .sheet(isPresented: $showingCalendar, onDismiss: {
                    // When calendar is dismissed, check if dates were selected and trigger search
                    if !viewModel.dates.isEmpty && !viewModel.fromIataCode.isEmpty && !viewModel.toIataCode.isEmpty {
                        viewModel.updateDatesAndRunSearch()
                    }
                }) {
                    CalendarView(
                        fromiatacode: $viewModel.fromIataCode,
                        toiatacode: $viewModel.toIataCode,
                        parentSelectedDates: $viewModel.dates,
                        onAnytimeSelection: { results in
                            viewModel.handleAnytimeResults(results)
                        },
                        onTripTypeChange: { newIsRoundTrip in
                            isRoundTrip = newIsRoundTrip
                            viewModel.isRoundTrip = newIsRoundTrip
                        },
                        isRoundTrip: isRoundTrip
                    )
                }
                .sheet(isPresented: $viewModel.showingPassengersSheet, onDismiss: {
                    triggerSearchAfterPassengerChange()
                }) {
                    PassengersAndClassSelector(
                        adultsCount: $viewModel.adultsCount,
                        childrenCount: $viewModel.childrenCount,
                        selectedClass: $viewModel.selectedCabinClass,
                        childrenAges: $viewModel.childrenAges
                    )
                }
                .onAppear {
                    viewModel.isRoundTrip = isRoundTrip
                }
                .onChange(of: isRoundTrip) { newValue in
                    viewModel.isRoundTrip = newValue
                    viewModel.handleTripTypeChange()
                }
            }
        }
    // MARK: - Helper Methods
    
    private func animatedSwapLocations() {
        // Only allow swap if both locations are set and not "Anywhere"
        guard !viewModel.fromIataCode.isEmpty && !viewModel.toIataCode.isEmpty,
              viewModel.toLocation != "Anywhere" else {
            return
        }
        
        // Animate 360 degrees rotation
        withAnimation(.easeInOut(duration: 0.6)) {
            swapRotationDegrees += 360
        }

        // Delay swap logic to align with animation duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Store original values before swapping
            let originalFromLocation = viewModel.fromLocation
            let originalFromCode = viewModel.fromIataCode
            let originalToLocation = viewModel.toLocation
            let originalToCode = viewModel.toIataCode
            
            // Perform swap
            viewModel.fromLocation = originalToLocation
            viewModel.fromIataCode = originalToCode
            viewModel.toLocation = originalFromLocation
            viewModel.toIataCode = originalFromCode
            
            // Update search context with swapped values
            viewModel.selectedOriginCode = viewModel.fromIataCode
            viewModel.selectedDestinationCode = viewModel.toIataCode
            
            // Clear existing results before new search
            viewModel.detailedFlightResults = []
            viewModel.flightResults = []
            
            // Trigger refetch based on current context
            if viewModel.showingDetailedFlightList {
                print("🔄 Swapping and refetching detailed flights: \(viewModel.fromIataCode) → \(viewModel.toIataCode)")
                
                viewModel.searchFlightsForDates(
                    origin: viewModel.fromIataCode,
                    destination: viewModel.toIataCode,
                    returnDate: viewModel.isRoundTrip ? viewModel.selectedReturnDatee : "",
                    departureDate: viewModel.selectedDepartureDatee,
                    isDirectSearch: viewModel.isDirectSearch
                )
            } else if viewModel.hasSearchedFlights {
                print("🔄 Swapping and refetching basic flights: \(viewModel.fromIataCode) → \(viewModel.toIataCode)")
                
                if viewModel.selectedCity != nil {
                    viewModel.fetchFlightDetails(destination: viewModel.toIataCode)
                } else {
                    viewModel.searchFlightsForDates(
                        origin: viewModel.fromIataCode,
                        destination: viewModel.toIataCode,
                        returnDate: viewModel.isRoundTrip ? viewModel.selectedReturnDatee : "",
                        departureDate: viewModel.selectedDepartureDatee,
                        isDirectSearch: true
                    )
                }
            } else if !viewModel.dates.isEmpty {
                print("🔄 Swapping and starting new search with dates: \(viewModel.fromIataCode) → \(viewModel.toIataCode)")
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                if viewModel.dates.count >= 2 {
                    let sortedDates = viewModel.dates.sorted()
                    viewModel.selectedDepartureDatee = formatter.string(from: sortedDates[0])
                    viewModel.selectedReturnDatee = formatter.string(from: sortedDates[1])
                } else if viewModel.dates.count == 1 {
                    viewModel.selectedDepartureDatee = formatter.string(from: viewModel.dates[0])
                    if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.dates[0]) {
                        viewModel.selectedReturnDatee = formatter.string(from: nextDay)
                    }
                }
                
                viewModel.searchFlightsForDates(
                    origin: viewModel.fromIataCode,
                    destination: viewModel.toIataCode,
                    returnDate: viewModel.isRoundTrip ? viewModel.selectedReturnDatee : "",
                    departureDate: viewModel.selectedDepartureDatee,
                    isDirectSearch: true
                )
            } else {
                print("🔄 Swapping with default dates: \(viewModel.fromIataCode) → \(viewModel.toIataCode)")
                
                let calendar = Calendar.current
                let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                let dayAfterTomorrow = calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                viewModel.selectedDepartureDatee = formatter.string(from: tomorrow)
                viewModel.selectedReturnDatee = formatter.string(from: dayAfterTomorrow)
                
                viewModel.dates = viewModel.isRoundTrip ? [tomorrow, dayAfterTomorrow] : [tomorrow]
                
                viewModel.searchFlightsForDates(
                    origin: viewModel.fromIataCode,
                    destination: viewModel.toIataCode,
                    returnDate: viewModel.isRoundTrip ? viewModel.selectedReturnDatee : "",
                    departureDate: viewModel.selectedDepartureDatee,
                    isDirectSearch: true
                )
            }
            
            print("✅ Swap completed and refetch initiated")
        }
    }

    private func getFromLocationDisplayText() -> String {
        if viewModel.fromIataCode.isEmpty {
            return "DEL Delhi"
        }
        return "\(viewModel.fromIataCode) \(viewModel.fromLocation)"
    }

    private func getFromLocationTextColor() -> Color {
        return .primary
    }

    private func getToLocationDisplayText() -> String {
        if viewModel.toIataCode.isEmpty {
            return viewModel.toLocation
        }
        return "\(viewModel.toIataCode) \(viewModel.toLocation)"
    }

    private func getToLocationTextColor() -> Color {
        return .primary
    }
        
    private func getDateDisplayText() -> String {
        if viewModel.dates.isEmpty && viewModel.selectedDepartureDatee.isEmpty {
            return "Anytime"
        }
        
        if viewModel.toLocation == "Anywhere" {
            return "Anytime"
        } else if viewModel.dates.isEmpty && viewModel.hasSearchedFlights && !viewModel.flightResults.isEmpty {
            return "Anytime"
        } else if viewModel.dates.isEmpty {
            return "Anytime"
        } else if viewModel.dates.count == 1 {
            return formatDate(viewModel.dates[0])
        } else if viewModel.dates.count >= 2 {
            return "\(formatDate(viewModel.dates[0])) - \(formatDate(viewModel.dates[1]))"
        }
        
        return "Anytime"
    }
    
    private func getDateTextColor() -> Color {
 
        return .primary
    }
    
    private func handleAnywhereDestination() {
        viewModel.goBackToCountries()
        viewModel.toLocation = "Anywhere"
        viewModel.toIataCode = ""
        viewModel.hasSearchedFlights = false
        viewModel.showingDetailedFlightList = false
        viewModel.flightResults = []
        viewModel.detailedFlightResults = []
    }
    
    private func triggerSearchAfterPassengerChange() {
        if viewModel.toLocation != "Anywhere" {
            if !viewModel.selectedOriginCode.isEmpty && !viewModel.selectedDestinationCode.isEmpty {
                viewModel.detailedFlightResults = []
                
                viewModel.searchFlightsForDates(
                    origin: viewModel.selectedOriginCode,
                    destination: viewModel.selectedDestinationCode,
                    returnDate: viewModel.isRoundTrip ? viewModel.selectedReturnDatee : "",
                    departureDate: viewModel.selectedDepartureDatee
                )
            }
            else if let city = viewModel.selectedCity {
                viewModel.fetchFlightDetails(destination: city.location.iata)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}



// MARK: - Flight Result Card
struct FlightResultCard: View {
    let departureDate: String
    let returnDate: String
    let origin: String
    let destination: String
    let price: String
    let isOutDirect: Bool
    let isInDirect: Bool
    let tripDuration: String
    @ObservedObject var viewModel: ExploreViewModel
    
    // FIXED: More robust validation that prevents glitching
    private var isValidCard: Bool {
        // Basic validation - don't show if essential data is missing or invalid
        guard !departureDate.isEmpty,
              !origin.isEmpty,
              !destination.isEmpty,
              !price.isEmpty,
              price != "₹0",
              departureDate != "No date" else {
            return false
        }
        return true
    }
    
    // Helper function to check if we should hide the card based on time
    private var shouldHideBasedOnTime: Bool {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentDate)
        
        // Check if current time is after 7 PM (19:00)
        guard currentHour >= 19 else { return false }
        
        // Parse the departure date string
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy"
        
        guard let flightDate = formatter.date(from: departureDate) else { return false }
        
        // Check if the flight date is today
        return calendar.isDate(flightDate, inSameDayAs: currentDate)
    }
    
    var body: some View {
        // FIXED: Only render if valid, use stable rendering approach
        if isValidCard && !shouldHideBasedOnTime {
            cardContent
                .id("\(origin)-\(destination)-\(departureDate)-\(price)") // Stable ID to prevent re-renders
        }
    }
    
    @ViewBuilder
    private var cardContent: some View {
        VStack(spacing: 5) {
            // Departure section
            VStack(alignment: .leading, spacing: 8) {
                Text("Departure")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text(String(departureDate.dropLast(5)))
                        .font(.headline)
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Text(origin)
                            .font(.headline)
                        
                        Image("flightresultarrrow")
                            .font(.caption)
                        
                        Text(destination)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Text(isOutDirect ? "Direct" : "Connecting")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("darkGreen"))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            // Return section - only show for round trips with valid return data
            if viewModel.isRoundTrip && !returnDate.isEmpty && returnDate != "No return" {
      
                VStack(alignment: .leading, spacing: 8) {
                    Text("Return")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text(String(returnDate.dropLast(5)))
                            .font(.headline)
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Text(destination)
                                .font(.headline)
                            
                            Image("flightresultarrrow")
                                .font(.caption)
                            
                            Text(origin)
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        Text(isInDirect ? "Direct" : "Connecting")
                            .font(.subheadline)
                            .foregroundColor(Color("darkGreen"))
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            
            Divider()
                .padding(.horizontal,16)
            
            // Price section
            HStack {
                VStack(alignment: .leading) {
                    Text("Flights from")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(price)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(viewModel.isRoundTrip ? tripDuration : "One way trip")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                                           
                    searchFlights()
                }) {
                    Text("View these dates")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 146,height: 46)
                        .background(Color("buttonColor"))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private func searchFlights() {
        // Use the formatted dates from the view model if available, otherwise fallback to card dates
        let formattedCardDepartureDate = viewModel.formatDateForAPI(from: self.departureDate) ?? "2025-11-25"
        let formattedCardReturnDate = viewModel.formatDateForAPI(from: self.returnDate) ?? "2025-11-27"
        
        // Create dates from the card dates to update the calendar selection
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // FIXED: Ensure proper context is set for trip type changes
        viewModel.selectedOriginCode = origin
        viewModel.selectedDestinationCode = destination
        viewModel.fromIataCode = origin
        viewModel.toIataCode = destination
        
        // Add separate handling for one-way vs. round trip
        if viewModel.isRoundTrip {
            if let departureDateObj = dateFormatter.date(from: formattedCardDepartureDate),
               let returnDateObj = dateFormatter.date(from: formattedCardReturnDate) {
                // Update the dates array in the view model to keep calendar in sync for round trip
                viewModel.dates = [departureDateObj, returnDateObj]
            }
            // Update the API date parameters
            viewModel.selectedDepartureDatee = formattedCardDepartureDate
            viewModel.selectedReturnDatee = formattedCardReturnDate
        } else {
            // One-way trip - just set departure date
            if let departureDateObj = dateFormatter.date(from: formattedCardDepartureDate) {
                viewModel.dates = [departureDateObj]
            }
            viewModel.selectedDepartureDatee = formattedCardDepartureDate
            viewModel.selectedReturnDatee = "" // Empty for one-way
        }
        
        // FIXED: Mark as direct search to ensure proper handling
        viewModel.isDirectSearch = true
        
        // Then call the search function with these dates
        viewModel.searchFlightsForDates(
            origin: origin,
            destination: destination,
            returnDate: viewModel.isRoundTrip ? formattedCardReturnDate : "",
            departureDate: formattedCardDepartureDate,
            isDirectSearch: true // Mark as direct search
        )
    }
}

// MARK: - API Destination Card
struct APIDestinationCard: View {
    @State private var cardScale: CGFloat = 1.0  // Start at normal scale
    @State private var isPressed = false
    let item: ExploreDestination
    let viewModel: ExploreViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            // Press feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                cardScale = 0.96
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    cardScale = 1.0
                }
                onTap()
            }
        }) {
            HStack(spacing: 0) { // Remove spacing to eliminate gap between image and content
                // OPTIMIZED AsyncImage with full height and left alignment
                CachedAsyncImage(
                    url: URL(string: "https://image.explore.lascadian.com/\(viewModel.showingCities ? "city" : "country")_\(item.location.entityId).webp")
                ) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 88, height: 88)
                        .clipped()
                        .cornerRadius(12, corners: [.topLeft, .bottomLeft]) // Only round left corners to match container
                } placeholder: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 88, height: 88)
                            .cornerRadius(12, corners: [.topLeft, .bottomLeft]) // Only round left corners
                        
                        VStack(spacing: 3) {
                            Image(systemName: viewModel.showingCities ? "building.2" : "globe")
                                .font(.system(size: 22))
                                .foregroundColor(.gray.opacity(0.7))
                            
                            Text(String(item.location.name.prefix(3)).uppercased())
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.gray.opacity(0.8))
                        }
                    }
                }
                
                // Content text with padding only on the right side
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        
                        
                        Text(item.location.name)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.bottom,2)
                        
                        Text(item.is_direct ? "Direct" : "Connecting")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack{
                        Text("Starting from")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.bottom,2)
                        Text(viewModel.formatPrice(item.price))
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                .padding(.leading, 12) // Add padding only on the left of text content
                .padding(.trailing, 12) // Add padding only on the right
                .padding(.vertical, 12) // Keep vertical padding
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(cardScale)
        // REMOVED: All slide-in animations (opacity, offset, cardAppeared state)
        .shadow(color: Color.black.opacity(isPressed ? 0.15 : 0.05), radius: isPressed ? 8 : 4, x: 0, y: isPressed ? 4 : 2)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed) // Only animate press state
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// Extension to add selective corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

class ImageCacheManager: ObservableObject {
    static let shared = ImageCacheManager()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Configure memory cache
        memoryCache.countLimit = 100 // Max 100 images in memory
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit
        
        // Set up disk cache directory
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache")
        
        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Clean old cache on startup
        cleanOldCache()
    }
    
    private func cacheKey(for url: URL) -> String {
        return url.absoluteString.data(using: .utf8)?.base64EncodedString() ?? url.absoluteString
    }
    
    private func diskCacheURL(for key: String) -> URL {
        return cacheDirectory.appendingPathComponent(key)
    }
    
    // MARK: - Cache Operations
    
    func cachedImage(for url: URL) -> UIImage? {
        let key = cacheKey(for: url)
        
        // Check memory cache first
        if let memoryImage = memoryCache.object(forKey: NSString(string: key)) {
            return memoryImage
        }
        
        // Check disk cache
        let diskURL = diskCacheURL(for: key)
        if fileManager.fileExists(atPath: diskURL.path),
           let data = try? Data(contentsOf: diskURL),
           let image = UIImage(data: data) {
            
            // Store in memory cache for next time
            memoryCache.setObject(image, forKey: NSString(string: key))
            return image
        }
        
        return nil
    }
    
    func cache(image: UIImage, for url: URL) {
        let key = cacheKey(for: url)
        
        // Store in memory cache
        memoryCache.setObject(image, forKey: NSString(string: key))
        
        // Store in disk cache
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self,
                  let data = image.jpegData(compressionQuality: 0.8) else { return }
            
            let diskURL = self.diskCacheURL(for: key)
            try? data.write(to: diskURL)
        }
    }
    
    func loadImage(from url: URL) -> AnyPublisher<UIImage, Error> {
        // Check cache first
        if let cachedImage = cachedImage(for: url) {
            return Just(cachedImage)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // Download and cache
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data -> UIImage in
                guard let image = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                return image
            }
            .handleEvents(receiveOutput: { [weak self] image in
                self?.cache(image: image, for: url)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Cache Management
    
    private func cleanOldCache() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            
            let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
            
            do {
                let contents = try self.fileManager.contentsOfDirectory(at: self.cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey])
                
                for fileURL in contents {
                    let attributes = try self.fileManager.attributesOfItem(atPath: fileURL.path)
                    if let modificationDate = attributes[.modificationDate] as? Date,
                       modificationDate < oneWeekAgo {
                        try self.fileManager.removeItem(at: fileURL)
                    }
                }
            } catch {
                print("Error cleaning cache: \(error)")
            }
        }
    }
    
    func clearCache() {
        memoryCache.removeAllObjects()
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            try? self.fileManager.removeItem(at: self.cacheDirectory)
            try? self.fileManager.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
        }
    }
}

// MARK: - Cached AsyncImage View
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @StateObject private var cacheManager = ImageCacheManager.shared
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var cancellable: AnyCancellable?
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let uiImage = image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        // Check if already cached
        if let cachedImage = cacheManager.cachedImage(for: url) {
            self.image = cachedImage
            return
        }
        
        isLoading = true
        
        cancellable = cacheManager.loadImage(from: url)
            .sink(
                receiveCompletion: { _ in
                    isLoading = false
                },
                receiveValue: { downloadedImage in
                    image = downloadedImage
                    isLoading = false
                }
            )
    }
}

// MARK: - Convenience Initializers
extension CachedAsyncImage where Content == Image, Placeholder == Color {
    init(url: URL?) {
        self.init(
            url: url,
            content: { image in image },
            placeholder: { Color.gray.opacity(0.15) }
        )
    }
}

extension CachedAsyncImage where Placeholder == Color {
    init(url: URL?, @ViewBuilder content: @escaping (Image) -> Content) {
        self.init(
            url: url,
            content: content,
            placeholder: { Color.gray.opacity(0.15) }
        )
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .blue : .black)
                .padding(.vertical, 3)
                .padding(.horizontal, 7)
                .background(isSelected ? Color.white : Color.clear)
                .clipShape(Capsule())
                .padding(5)
        }
    }
}


// MARK: - Updated TripTypeTabView with Conditional Multi-City Display
struct TripTypeTabView: View {
    @Binding var selectedTab: Int
    @Binding var isRoundTrip: Bool
    @ObservedObject var viewModel: ExploreViewModel
    
    // ADD: Observe shared search data to determine if multi-city should be shown
    @StateObject private var sharedSearchData = SharedSearchDataStore.shared
    
    // Conditional tabs based on search mode and original search type
    private var availableTabs: [String] {
        // Only show multi-city if user came from direct search AND original search was multi-city
        if sharedSearchData.isInSearchMode && sharedSearchData.selectedTab == 2 {
            return ["Return", "One way", "Multi city"]
        } else {
            return ["Return", "One way"]
        }
    }
    
    // Calculate dimensions based on available tabs - Updated to match tripTypeTabs UI
    private var totalWidth: CGFloat {
        return UIScreen.main.bounds.width * 0.65
    }
    
    private var tabWidth: CGFloat {
        return totalWidth / CGFloat(availableTabs.count)
    }
    
    private var padding: CGFloat {
        return 6 // Consistent padding for all sides
    }
    
    // MARK: - Targeted Loading State Check
    private var isLoadingInDetailedView: Bool {
        return viewModel.showingDetailedFlightList &&
               (viewModel.isLoadingDetailedFlights ||
                (viewModel.detailedFlightResults.isEmpty && viewModel.isLoadingDetailedFlights))
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background capsule (gray background, height remains the same)
            Capsule()
                .fill(Color(UIColor.systemGray6))
                .frame(height: 44)  // Keep the gray background height at 44
                
            // Sliding white background for selected tab (height slightly increased)
            Capsule()
                .fill(Color.white)
                .frame(width: tabWidth - (padding * 2), height: 34)  // Slightly increased height of the white background
                .offset(x: (CGFloat(selectedTab) * tabWidth) + padding)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            
            // Tab buttons row with conditional tabs
            HStack(spacing: 0) {
                ForEach(0..<availableTabs.count, id: \.self) { index in
                    Button(action: {
                        // TARGETED SAFETY CHECK: Only block changes in ModifiedDetailedFlightListView during loading
                        if isLoadingInDetailedView {
                            print("Trip type change blocked - skeleton loading in detailed flight view")
                            return
                        }
                        
                        selectedTab = index
                        
                        // Handle multi-city selection (only if available)
                        if index == 2 && availableTabs.count > 2 {
                            // Initialize multi city trips
                            viewModel.initializeMultiCityTrips()
                        } else {
                            // Handle return/one-way trip types
                            let newIsRoundTrip = (index == 0)
                            
                            if isRoundTrip != newIsRoundTrip {
                                // Update the trip type
                                isRoundTrip = newIsRoundTrip
                                viewModel.isRoundTrip = newIsRoundTrip
                                
                                // Call the centralized method
                                viewModel.handleTripTypeChange()
                            }
                        }
                    }) {
                        Text(availableTabs[index])
                            .font(.system(size: 13, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundColor(
                                isLoadingInDetailedView ? .gray.opacity(0.5) : (selectedTab == index ? .blue : .primary)
                            )
                            .frame(width: tabWidth)
                            .padding(.vertical, 8)
                    }
                    .disabled(isLoadingInDetailedView)
                }
            }
            .onChange(of: isRoundTrip) { newValue in
                // Update selectedTab to match the trip type only if not loading in detailed view
                if !isLoadingInDetailedView {
                    selectedTab = newValue ? 0 : 1 // 0 for "Return", 1 for "One way"
                }
            }
        }
        .frame(width: totalWidth, height: 36)
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
        .opacity(isLoadingInDetailedView ? 0.6 : 1.0)
        .onReceive(sharedSearchData.$isInSearchMode) { _ in
            // Reset selectedTab when search mode changes and multi-city is not available
            if !sharedSearchData.isInSearchMode || sharedSearchData.selectedTab != 2 {
                if selectedTab >= availableTabs.count {
                    selectedTab = 0 // Reset to "Return" if current tab is not available
                }
            }
        }
    }
}

// MARK: - Filter Tab Button Component
struct FilterTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .blue : .black)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? Color.blue : Color.clear,
                            lineWidth: isSelected ? 1 : 0
                        )
                )
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle()) // Prevents button highlighting issues
    }
}

struct MultiCitySearchCard: View {
    @ObservedObject var viewModel: ExploreViewModel
    @State private var showingSearchSheet = false
    @State private var initialFocus: LocationSearchSheet.SearchBarType = .origin
    @State private var showingCalendar = false
    @State private var editingTripIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Multi-city trips grid
            VStack(spacing: 0) {
                ForEach(0..<viewModel.multiCityTrips.count, id: \.self) { index in
                    multiCityTripRow(for: index)
                    
                    // Add divider between rows (except for last row)
                    if index < viewModel.multiCityTrips.count - 1 {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            
            // Bottom section with passenger info and add flight
            VStack(spacing: 0) {
                Divider()
                    .padding(.horizontal, 16)
                
                HStack {
                    // Passenger info button
                    Button(action: {
                        // Handle passenger selection
                    }) {
                        HStack(spacing: 8) {
                            Image("cardpassenger")
                                .foregroundColor(.primary)
                                .font(.system(size: 16))
                            
                            Text(getPassengerDisplayText())
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    // Add flight button
                    Button(action: {
                        addNewTrip()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Add flight")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .sheet(isPresented: $showingSearchSheet) {
            LocationSearchSheet(
                viewModel: viewModel,
                initialFocus: initialFocus,
             
            )
        }
        .sheet(isPresented: $showingCalendar) {
            CalendarView(
                fromiatacode: .constant(viewModel.multiCityTrips[editingTripIndex].fromIataCode),
                toiatacode: .constant(viewModel.multiCityTrips[editingTripIndex].toIataCode),
                parentSelectedDates: .constant([viewModel.multiCityTrips[editingTripIndex].date]),
                onAnytimeSelection: { _ in },
                onTripTypeChange: { _ in },
                isRoundTrip: false
            )
        }
    }
    
    // MARK: - Individual Trip Row
    @ViewBuilder
    private func multiCityTripRow(for index: Int) -> some View {
        let trip = viewModel.multiCityTrips[index]
        
        HStack(spacing: 12) {
            // Origin and Destination section
            HStack(spacing: 8) {
                // From location
                Button(action: {
                    editingTripIndex = index
                    initialFocus = .origin
                    showingSearchSheet = true
                }) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trip.fromIataCode.isEmpty ? "COK" : trip.fromIataCode)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(trip.fromLocation.isEmpty ? "From" : trip.fromLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Arrow or connector
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                
                // To location
                Button(action: {
                    editingTripIndex = index
                    initialFocus = .destination
                    showingSearchSheet = true
                }) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trip.toIataCode.isEmpty ? "DXB" : trip.toIataCode)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(trip.toLocation.isEmpty ? "To" : trip.toLocation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            // Date section
            Button(action: {
                editingTripIndex = index
                showingCalendar = true
            }) {
                Text(formatTripDate(trip.date))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(minWidth: 80, alignment: .leading)
            }
            
            // Delete button
            if viewModel.multiCityTrips.count > 2 {
                Button(action: {
                    removeTrip(at: index)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                        .frame(width: 24, height: 24)
                }
            } else {
                // Invisible spacer to maintain layout
                Spacer()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Helper Methods
    private func getPassengerDisplayText() -> String {
        let adults = viewModel.adultsCount
        let children = viewModel.childrenCount
        let totalPassengers = adults + children
        
        if totalPassengers == 1 {
            return "1, Economy"
        } else if children == 0 {
            return "\(adults), Economy"
        } else {
            return "\(totalPassengers), Economy"
        }
    }
    
    private func formatTripDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        return formatter.string(from: date)
    }
    
    private func addNewTrip() {
        guard viewModel.multiCityTrips.count < 5 else { return }
        
        let lastTrip = viewModel.multiCityTrips.last!
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: lastTrip.date) ?? Date()
        
        let newTrip = MultiCityTrip(
            fromLocation: lastTrip.toLocation,
            fromIataCode: lastTrip.toIataCode,
            toLocation: "To",
            toIataCode: "",
            date: nextDay
        )
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            viewModel.multiCityTrips.append(newTrip)
        }
    }
    
    private func removeTrip(at index: Int) {
        guard viewModel.multiCityTrips.count > 2,
              index < viewModel.multiCityTrips.count else { return }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            viewModel.multiCityTrips.remove(at: index)
        }
    }
}

// This is a simple wrapper around existing LocationSearchSheet
struct MultiCityLocationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ExploreViewModel
    var initialFocus: LocationSearchSheet.SearchBarType
    var tripIndex: Int
    
    @State private var searchText = ""
    @State private var selectedLocation = ""
    
    var body: some View {
        LocationSearchSheet(
            viewModel: viewModel,
            multiCityMode: true, multiCityTripIndex: tripIndex, initialFocus: initialFocus
        )
    }
}


// MARK: - Updated Loading Border View with Rotating Gradient Segments
struct LoadingBorderView: View {
    @State private var rotationAngle: Double = 0

    var body: some View {
        ZStack {
            // Base stroke
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 3.0)

            // Reversed gradient stroke (tail to head)
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.clear, location: 0.0),
                            .init(color: Color.orange.opacity(0.1), location: 0.3),
                            .init(color: Color.orange, location: 0.8),
                            .init(color: Color.orange, location: 1.0)
                        ]),
                        center: .center,
                        startAngle: .degrees(rotationAngle),
                        endAngle: .degrees(rotationAngle + 360)
                    ),
                    lineWidth: 3.0
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}




// MARK: - Enhanced Skeleton Destination Card
struct SkeletonDestinationCard: View {
    var body: some View {
        EnhancedSkeletonDestinationCard()
    }
}


// MARK: - Enhanced Skeleton Flight Result Card
struct SkeletonFlightResultCard: View {
    var body: some View {
        EnhancedSkeletonFlightResultCard()
    }
}

// Add this new component:

struct MonthSelectorView: View {
    let months: [Date]
    let selectedIndex: Int
    let onSelect: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<months.count, id: \.self) { index in
                    MonthButton(
                        month: months[index],
                        isSelected: selectedIndex == index,
                        action: {
                            onSelect(index)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MonthButton: View {
    let month: Date
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(monthName(from: month))
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .blue : .black)
                
                Text(year(from: month))
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color.blue : Color.clear,
                        lineWidth: isSelected ? 1 : 0
                    )
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle()) // Prevents button highlighting issues
    }
    
    private func monthName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    private func year(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
}



// MARK: - Modified LocationSearchSheet with "Anywhere" option

struct LocationSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ExploreViewModel
    @State private var originSearchText = ""
    @State private var destinationSearchText = ""
    @State private var results: [AutocompleteResult] = []
    @State private var isSearching = false
    @State private var searchError: String? = nil
    @State private var activeSearchBar: SearchBarType = .origin
    @FocusState private var focusedField: SearchBarType?
    
    var multiCityMode: Bool = false
    var multiCityTripIndex: Int = 0

    enum SearchBarType {
        case origin
        case destination
    }

    var initialFocus: SearchBarType
    private let debouncer = Debouncer(delay: 0.3)

    var body: some View {
        VStack(spacing: 0) {
            // Header section
            headerView()
            
            // Search bars
            originSearchBarView()
            destinationSearchBarView()
            
            // Current location button
            currentLocationButtonView()
            
            Divider()
            
            // Results section
            resultsView()
            
            Spacer()
        }
        .background(Color.white)
        .onAppear {
            // Set the initial focus
            activeSearchBar = initialFocus
            focusedField = initialFocus
        }
    }
    
    // MARK: - Component Views
    
    private func headerView() -> some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text(activeSearchBar == .origin ? "From Where?" : "Where to?")
                .font(.headline)
            
            Spacer()
            
            // Empty space to balance the X button
            Image(systemName: "xmark")
                .font(.system(size: 18))
                .foregroundColor(.clear)
        }
        .padding()
    }
    
    private func originSearchBarView() -> some View {
        HStack {
            TextField("", text: $originSearchText)
                .placeholder(when: originSearchText.isEmpty) {
                    Text("Origin City, Airport or place")
                        .foregroundColor(.gray)
                }
                .padding(12)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(activeSearchBar == .origin ? Color.orange : Color.gray, lineWidth: 2)
                )
                .cornerRadius(8)
                .focused($focusedField, equals: .origin)
                .onChange(of: originSearchText) {
                    handleOriginTextChange()
                }
                .onTapGesture {
                    activeSearchBar = .origin
                    focusedField = .origin
                }
            
            if !originSearchText.isEmpty {
                Button(action: {
                    originSearchText = ""
                    if activeSearchBar == .origin {
                        results = []
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
    
    private func destinationSearchBarView() -> some View {
        HStack {
            TextField("", text: $destinationSearchText)
                .placeholder(when: destinationSearchText.isEmpty) {
                    Text("Destination City, Airport or place")
                        .foregroundColor(.gray)
                }
                .padding(12)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(activeSearchBar == .destination ? Color.orange : Color.gray, lineWidth: 2)
                )
                .cornerRadius(8)
                .focused($focusedField, equals: .destination)
                .onChange(of: destinationSearchText) {
                    handleDestinationTextChange()
                }
                .onTapGesture {
                    activeSearchBar = .destination
                    focusedField = .destination
                }
            
            if !destinationSearchText.isEmpty {
                Button(action: {
                    destinationSearchText = ""
                    if activeSearchBar == .destination {
                        results = []
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func currentLocationButtonView() -> some View {
        Group {
            if activeSearchBar == .origin {
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
            }
        }
    }
    
    // MODIFIED: Updated results view to include "Anywhere" option for destination
    private func resultsView() -> some View {
        Group {
            if isSearching {
                searchingView()
            } else if let error = searchError {
                // Make the error more visible to the user
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
            } else if shouldShowNoResults() {
                noResultsView()
            } else {
                resultsList()
            }
        }
    }
    
    private func searchingView() -> some View {
        VStack {
            ProgressView()
            Text("Searching...")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    private func noResultsView() -> some View {
        Text("No results found")
            .foregroundColor(.gray)
            .padding()
    }
    
    // MODIFIED: Updated results list to include "Anywhere" option
    private func resultsList() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Show "Anywhere" option only for destination search
                if activeSearchBar == .destination {
                    AnywhereOptionRow()
                        .onTapGesture {
                            handleAnywhereSelection()
                        }
                    
                    // Add a divider after "Anywhere" option if there are other results
                    if !results.isEmpty {
                        Divider()
                            .padding(.horizontal)
                    }
                }
                
                ForEach(results) { result in
                    LocationResultRow(result: result)
                        .onTapGesture {
                            handleResultSelection(result: result)
                        }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleOriginTextChange() {
        activeSearchBar = .origin
        if !originSearchText.isEmpty {
            debouncer.debounce {
                searchLocations(query: originSearchText)
            }
        } else {
            results = []
        }
    }
    
    private func handleDestinationTextChange() {
        activeSearchBar = .destination
        if !destinationSearchText.isEmpty {
            debouncer.debounce {
                searchLocations(query: destinationSearchText)
            }
        } else {
            results = []
        }
    }
    
    private func shouldShowNoResults() -> Bool {
        let emptyResults = results.isEmpty
        let activeOriginWithText = activeSearchBar == .origin && !originSearchText.isEmpty
        let activeDestinationWithText = activeSearchBar == .destination && !destinationSearchText.isEmpty
        
        return emptyResults && (activeOriginWithText || activeDestinationWithText)
    }
    
    private func useCurrentLocation() {
        viewModel.fromLocation = "Current Location"
        viewModel.fromIataCode = "DEL" // Using Delhi as default
        originSearchText = "Current Location"
        
        activeSearchBar = .destination
        focusedField = .destination
    }
    
    // NEW: Handle "Anywhere" selection
    private func handleAnywhereSelection() {
        if multiCityMode {
            viewModel.multiCityTrips[multiCityTripIndex].toLocation = "Anywhere"
            viewModel.multiCityTrips[multiCityTripIndex].toIataCode = ""
        } else {
            viewModel.toLocation = "Anywhere"
            viewModel.toIataCode = ""
            destinationSearchText = "Anywhere"
        }
        
        dismiss()
    }
    
    private func handleResultSelection(result: AutocompleteResult) {
        if activeSearchBar == .origin {
            selectOrigin(result: result)
        } else {
            // Check if the selected destination is the same as origin
            if result.iataCode == viewModel.fromIataCode {
                // Don't allow selection of the same destination as origin
                // Show a message to the user
                searchError = "Origin and destination cannot be the same"
                return
            }
            selectDestination(result: result)
        }
    }
    
    private func selectOrigin(result: AutocompleteResult) {
        // Check if this would match the current destination
        if !viewModel.toIataCode.isEmpty && result.iataCode == viewModel.toIataCode {
            searchError = "Origin and destination cannot be the same"
            return
        }
        
        if multiCityMode {
            viewModel.multiCityTrips[multiCityTripIndex].fromLocation = result.cityName
            viewModel.multiCityTrips[multiCityTripIndex].fromIataCode = result.iataCode
        } else {
            viewModel.fromLocation = result.cityName
            viewModel.fromIataCode = result.iataCode
            originSearchText = result.cityName
        }
        
        // Check if we should proceed with search or just dismiss
        if multiCityMode {
            // For multi-city, just auto-focus destination if it's empty
            if viewModel.multiCityTrips[multiCityTripIndex].toIataCode.isEmpty {
                activeSearchBar = .destination
                focusedField = .destination
            } else {
                dismiss()
            }
        } else {
            // For regular mode, check if we have both locations for automatic search
            if !viewModel.toIataCode.isEmpty {
                // Both origin and destination are selected, dismiss and potentially search
                dismiss()
                
                // If user has selected dates, trigger search
                if !viewModel.dates.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.updateDatesAndRunSearch()
                    }
                } else {
                    // If no dates selected, use dynamic default dates for search
                    initiateSearchWithDefaultDates()
                }
            } else {
                // Only origin selected, auto-focus the destination field
                activeSearchBar = .destination
                focusedField = .destination
            }
        }
    }
    
    private func selectDestination(result: AutocompleteResult) {
        if multiCityMode {
            viewModel.multiCityTrips[multiCityTripIndex].toLocation = result.cityName
            viewModel.multiCityTrips[multiCityTripIndex].toIataCode = result.iataCode
            dismiss()
        } else {
            // Update the destination in view model
            viewModel.toLocation = result.cityName
            viewModel.toIataCode = result.iataCode
            destinationSearchText = result.cityName
            
            // Check if we should proceed with search or just dismiss
            if !viewModel.fromIataCode.isEmpty {
                // Both origin and destination are selected, dismiss and potentially search
                dismiss()
                
                // If user has selected dates, trigger search
                if !viewModel.dates.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.updateDatesAndRunSearch()
                    }
                } else {
                    // If no dates selected, use dynamic default dates for search
                    initiateSearchWithDefaultDates()
                }
            } else {
                // Only destination selected, auto-focus the origin field
                activeSearchBar = .origin
                focusedField = .origin
            }
        }
    }
    
    // Add this helper function to handle default date search
    private func initiateSearchWithDefaultDates() {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let departureDate = formatter.string(from: tomorrow)
        let returnDate = formatter.string(from: dayAfterTomorrow)
        
        viewModel.selectedDepartureDatee = departureDate
        viewModel.selectedReturnDatee = returnDate
        
        // Also update the dates array to keep calendar in sync
        viewModel.dates = [tomorrow, dayAfterTomorrow]
        
        // Initiate flight search with dynamic default dates - mark as direct search
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.searchFlightsForDates(
                origin: viewModel.fromIataCode,
                destination: viewModel.toIataCode,
                returnDate: returnDate,
                departureDate: departureDate,
                isDirectSearch: true
            )
        }
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
            .store(in: &viewModel.cancellables)
    }
}

// NEW: Custom view for the "Anywhere" option
struct AnywhereOptionRow: View {
    var body: some View {
        HStack(spacing: 16) {
            // Icon for "Anywhere"
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "globe")
                    .font(.system(size: 18))
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Anywhere")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("Explore destinations")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "arrow.up.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .contentShape(Rectangle())
    }
}

// Helper view for placeholder text in TextField
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Row view for displaying search results
struct LocationResultRow: View {
    let result: AutocompleteResult
    
    var body: some View {
        HStack(spacing: 16) {
            Text(result.iataCode)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 40, height: 40)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(result.cityName), \(result.countryName)")
                    .font(.system(size: 16, weight: .medium))
                
                Text(result.type == "airport" ? result.airportName : "All Airports")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
    }
}

// Simple debouncer to avoid excessive API calls
class Debouncer {
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

struct FlightTag: Identifiable {
let id = UUID()
let title: String
let color: Color

static let best = FlightTag(title: "Best", color: Color.blue)
static let cheapest = FlightTag(title: "Cheapest", color: Color.green)
static let fastest = FlightTag(title: "Fastest", color: Color.purple)
}



// Updated Flight Card Components to match the UI design

// REPLACE the existing DetailedFlightCardWrapper in ExploreComponents.swift with this corrected version:

struct DetailedFlightCardWrapper: View {
    let result: FlightDetailResult
    @ObservedObject var viewModel: ExploreViewModel
    var onTap: () -> Void
    
    var body: some View {
        if let outboundLeg = result.legs.first, !outboundLeg.segments.isEmpty {
            let outboundSegment = outboundLeg.segments.first!
            
            Button(action: onTap) {
                // Check if this is a multi-city trip (more than 2 legs)
                if result.legs.count > 2 {
                    // Multi-city trip - show all legs in one card
                    MultiCityModernFlightCard(
                        result: result,
                        viewModel: viewModel
                    )
                } else {
                    // Regular trip (return or one-way) - use existing logic
                    let returnLeg = viewModel.isRoundTrip && result.legs.count >= 2 ? result.legs.last : nil
                    let returnSegment = returnLeg?.segments.first
                    
                    // Format time and dates
                    let outboundDepartureTime = formatTime(from: outboundSegment.departureTimeAirport)
                    let outboundArrivalTime = formatTime(from: outboundSegment.arriveTimeAirport)
                    
                    if viewModel.isRoundTrip && returnLeg != nil && returnSegment != nil {
                        // Round trip flight card (2 rows)
                        ModernFlightCard(
                            // Tags
                            isBest: result.isBest,
                            isCheapest: result.isCheapest,
                            isFastest: result.isFastest,
                            
                            // Outbound flight
                            outboundDepartureTime: outboundDepartureTime,
                            outboundDepartureCode: outboundSegment.originCode,
                            outboundDepartureDate: formatDateShort(from: outboundSegment.departureTimeAirport),
                            outboundArrivalTime: outboundArrivalTime,
                            outboundArrivalCode: outboundSegment.destinationCode,
                            outboundArrivalDate: formatDateShort(from: outboundSegment.arriveTimeAirport),
                            outboundDuration: formatDuration(minutes: outboundLeg.duration),
                            isOutboundDirect: outboundLeg.stopCount == 0,
                            outboundStops: outboundLeg.stopCount,
                            
                            // Return flight
                            returnDepartureTime: formatTime(from: returnSegment!.departureTimeAirport),
                            returnDepartureCode: returnSegment!.originCode,
                            returnDepartureDate: formatDateShort(from: returnSegment!.departureTimeAirport),
                            returnArrivalTime: formatTime(from: returnSegment!.arriveTimeAirport),
                            returnArrivalCode: returnSegment!.destinationCode,
                            returnArrivalDate: formatDateShort(from: returnSegment!.arriveTimeAirport),
                            returnDuration: formatDuration(minutes: returnLeg!.duration),
                            isReturnDirect: returnLeg!.stopCount == 0,
                            returnStops: returnLeg!.stopCount,
                            
                            // Airline and price
                            OutboundAirline: outboundSegment.airlineName,
                            OutboundAirlineCode: outboundSegment.airlineIata,
                            OutboundAirlineLogo: outboundSegment.airlineLogo,
                            
                            ReturnAirline: returnSegment!.airlineName,
                            ReturnAirlineCode: returnSegment!.airlineIata,
                            ReturnAirlineLogo: returnSegment!.airlineLogo,
                            
                            price: "₹\(Int(result.minPrice))",
                            priceDetail: "For \(viewModel.adultsCount + viewModel.childrenCount) People ₹\(Int(result.minPrice * Double(viewModel.adultsCount + viewModel.childrenCount)))",
                            
                            isRoundTrip: true
                        )
                    } else {
                        // One way flight card (1 row)
                        ModernFlightCard(
                            // Tags
                            isBest: result.isBest,
                            isCheapest: result.isCheapest,
                            isFastest: result.isFastest,
                            
                            // Outbound flight
                            outboundDepartureTime: outboundDepartureTime,
                            outboundDepartureCode: outboundSegment.originCode,
                            outboundDepartureDate: formatDateShort(from: outboundSegment.departureTimeAirport),
                            outboundArrivalTime: outboundArrivalTime,
                            outboundArrivalCode: outboundSegment.destinationCode,
                            outboundArrivalDate: formatDateShort(from: outboundSegment.arriveTimeAirport),
                            outboundDuration: formatDuration(minutes: outboundLeg.duration),
                            isOutboundDirect: outboundLeg.stopCount == 0,
                            outboundStops: outboundLeg.stopCount,
                            
                            // For one-way trips, use outbound airline data for both parameters
                            OutboundAirline: outboundSegment.airlineName,
                            OutboundAirlineCode: outboundSegment.airlineIata,
                            OutboundAirlineLogo: outboundSegment.airlineLogo,
                            
                            ReturnAirline: outboundSegment.airlineName,
                            ReturnAirlineCode: outboundSegment.airlineIata,
                            ReturnAirlineLogo: outboundSegment.airlineLogo,
                            
                            price: "₹\(Int(result.minPrice))",
                            priceDetail: "For \(viewModel.adultsCount + viewModel.childrenCount) People ₹\(Int(result.minPrice * Double(viewModel.adultsCount + viewModel.childrenCount)))",
                            
                            isRoundTrip: false
                        )
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            Text("Incomplete flight details")
                .foregroundColor(.gray)
                .padding()
        }
    }
    
    // Helper functions for formatting
    private func formatTime(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDateShort(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}

// REPLACE the MultiCityModernFlightCard in ExploreComponents.swift with this corrected version:

struct MultiCityModernFlightCard: View {
    let result: FlightDetailResult
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            // Tags at the top (same style as ModernFlightCard)
            if result.isBest || result.isCheapest || result.isFastest {
                HStack(spacing: 4) {
                    if result.isBest {
                        TagView(text: "Best", color: Color("best"))
                    }
                    if result.isCheapest {
                        TagView(text: "Cheapest", color: Color("cheap"))
                    }
                    if result.isFastest {
                        TagView(text: "Fastest", color: Color("fast"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 4)
            }
            
            // Display each leg (3-4 rows for multi-city) - NO DIVIDERS BETWEEN ROWS
            ForEach(0..<result.legs.count, id: \.self) { index in
                let leg = result.legs[index]
                
                if let segment = leg.segments.first {
                    // Use the same FlightRowView style as ModernFlightCard
                    FlightRowView(
                        departureTime: formatTime(from: segment.departureTimeAirport),
                        departureCode: segment.originCode,
                        departureDate: formatDateShort(from: segment.departureTimeAirport),
                        arrivalTime: formatTime(from: segment.arriveTimeAirport),
                        arrivalCode: segment.destinationCode,
                        arrivalDate: formatDateShort(from: segment.arriveTimeAirport),
                        duration: formatDuration(minutes: leg.duration),
                        isDirect: leg.stopCount == 0,
                        stops: leg.stopCount,
                        airlineName: segment.airlineName,
                        airlineCode: segment.airlineIata,
                        airlineLogo: segment.airlineLogo
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
            }
            
            // ONLY ONE DIVIDER - Above the price section
            Divider()
                .padding()
            
            // Bottom section with price (same style as ModernFlightCard)
            HStack {
                Text(getAirlineDisplayText())
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("₹\(Int(result.minPrice))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("For \(viewModel.adultsCount + viewModel.childrenCount) People")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    // Helper function to display airline info for multi-city
    private func getAirlineDisplayText() -> String {
        let airlines = result.legs.compactMap { $0.segments.first?.airlineName }
        let uniqueAirlines = Array(Set(airlines))
        
        if uniqueAirlines.count == 1 {
            return uniqueAirlines.first ?? "Multi-city Trip"
        } else if uniqueAirlines.count == 2 {
            return "\(uniqueAirlines[0]) & 1 other"
        } else {
            return "\(uniqueAirlines.first ?? "") & \(uniqueAirlines.count - 1) others"
        }
    }
    
    // Helper functions (same as DetailedFlightCardWrapper)
    private func formatTime(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDateShort(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}

// ADD TagView if it doesn't exist:
struct TagView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(color)
            .cornerRadius(4)
    }
}



// Updated ModernFlightCard with reduced padding to match sample UI
struct ModernFlightCard: View {
    // Tags
    let isBest: Bool
    let isCheapest: Bool
    let isFastest: Bool
    
    // Outbound flight
    let outboundDepartureTime: String
    let outboundDepartureCode: String
    let outboundDepartureDate: String
    let outboundArrivalTime: String
    let outboundArrivalCode: String
    let outboundArrivalDate: String
    let outboundDuration: String
    let isOutboundDirect: Bool
    let outboundStops: Int
    
    // Return flight (optional)
    var returnDepartureTime: String? = nil
    var returnDepartureCode: String? = nil
    var returnDepartureDate: String? = nil
    var returnArrivalTime: String? = nil
    var returnArrivalCode: String? = nil
    var returnArrivalDate: String? = nil
    var returnDuration: String? = nil
    var isReturnDirect: Bool? = nil
    var returnStops: Int? = nil
    
    // Airline and price
    let OutboundAirline: String
    let OutboundAirlineCode: String
    let OutboundAirlineLogo: String
    
    let ReturnAirline: String
    let ReturnAirlineCode: String
    let ReturnAirlineLogo: String
    
    let price: String
    let priceDetail: String
    
    let isRoundTrip: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Tags at the top inside the card - REDUCED PADDING
            if isBest || isCheapest || isFastest {
                HStack(spacing: 4) { // Reduced from 6 to 4
                    if isBest {
                        TagView(text: "Best", color: Color("best"))
                    }
                    if isCheapest {
                        TagView(text: "Cheapest",color: Color("cheap"))
                    }
                    if isFastest {
                        TagView(text: "Fastest", color: Color("fast"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 12) // Reduced from 16 to 12
                .padding(.top, 12) // Reduced from 12 to 8
                .padding(.bottom, 2) // Reduced from 8 to 4
            }
            
            // Outbound flight - REDUCED PADDING
            FlightRowView(
                departureTime: outboundDepartureTime,
                departureCode: outboundDepartureCode,
                departureDate: outboundDepartureDate,
                arrivalTime: outboundArrivalTime,
                arrivalCode: outboundArrivalCode,
                arrivalDate: outboundArrivalDate,
                duration: outboundDuration,
                isDirect: isOutboundDirect,
                stops: outboundStops,
                airlineName: OutboundAirline,
                airlineCode: OutboundAirlineCode,
                airlineLogo: OutboundAirlineLogo
            )
            .padding(.horizontal, 12) // Reduced from 16 to 12
            .padding(.vertical, 8) // Reduced from default to 8
            
            // Return flight (if round trip) - REDUCED PADDING
            if isRoundTrip,
               let retDepTime = returnDepartureTime,
               let retDepCode = returnDepartureCode,
               let retDepDate = returnDepartureDate,
               let retArrTime = returnArrivalTime,
               let retArrCode = returnArrivalCode,
               let retArrDate = returnArrivalDate,
               let retDuration = returnDuration,
               let retDirect = isReturnDirect,
               let retStops = returnStops {
                
                FlightRowView(
                    departureTime: retDepTime,
                    departureCode: retDepCode,
                    departureDate: retDepDate,
                    arrivalTime: retArrTime,
                    arrivalCode: retArrCode,
                    arrivalDate: retArrDate,
                    duration: retDuration,
                    isDirect: retDirect,
                    stops: retStops,
                    airlineName: ReturnAirline,
                    airlineCode: ReturnAirlineCode,
                    airlineLogo: ReturnAirlineLogo
                )
                .padding(.horizontal, 12) // Reduced from 16 to 12
                .padding(.vertical, 8) // Reduced from 8 to 6
            }
            
            // Bottom section with airline and price - REDUCED PADDING
            Divider()
                .padding(.horizontal, 12) // Reduced from 16 to 12
                .padding(.bottom) // Reduced from default to 6
            
            HStack {
                Text(airlineDisplayText())
                    .font(.system(size: 14))
                    .foregroundColor(Color.black.opacity(0.6))
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(price)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(priceDetail)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 12) // Reduced from 16 to 12
            .padding(.vertical, 8) // Reduced from 12 to 8
            .padding(.bottom,2)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    private func airlineDisplayText() -> String {
        if !isRoundTrip {
            // One-way flight, just show outbound airline
            return OutboundAirline
        } else {
            // Round trip flight
            if OutboundAirline == ReturnAirline {
                // Same airline for both flights
                return OutboundAirline
            } else {
                // Different airlines
                return "\(OutboundAirline) & 1 other"
            }
        }
    }
}

// Updated FlightRowView with reduced spacing and padding
struct FlightRowView: View {
    let departureTime: String
    let departureCode: String
    let departureDate: String
    let arrivalTime: String
    let arrivalCode: String
    let arrivalDate: String
    let duration: String
    let isDirect: Bool
    let stops: Int
    
    // Add airline information for the flight image
    let airlineName: String
    let airlineCode: String
    let airlineLogo: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) { // Reduced from 12 to 8
            // Flight/Airline image section - SMALLER SIZE
            AsyncImage(url: URL(string: airlineLogo)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28) // Reduced from 32 to 28
                        .clipShape(RoundedRectangle(cornerRadius: 5)) // Reduced from 6 to 5
                case .failure(_), .empty:
                    // Fallback airline logo
                    ZStack {
                        RoundedRectangle(cornerRadius: 5) // Reduced from 6 to 5
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 28, height: 28) // Reduced from 32 to 28
                        
                        Text(String(airlineCode.prefix(2)))
                            .font(.system(size: 11, weight: .bold)) // Reduced from 12 to 11
                            .foregroundColor(.blue)
                    }
                @unknown default:
                    // Default placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "airplane")
                            .font(.system(size: 12)) // Reduced from 14 to 12
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Departure section - TIGHTER SPACING
            VStack(alignment: .leading, spacing: 2) { // Reduced from 4 to 2
                Text(departureTime)
                    .font(.system(size: 16, weight: .semibold)) // Reduced from 18 to 16
                    .foregroundColor(.black)
                
                // Departure code and date in the same row (HStack)
                HStack(spacing: 4) { // Reduced from 8 to 6
                    Text(departureCode)
                        .font(.system(size: 13)) // Reduced from 14 to 13
                        .foregroundColor(.gray)
                    
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 4, height: 4)
                    
                    Text(departureDate)
                        .font(.system(size: 11)) // Reduced from 12 to 11
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 80, alignment: .leading) // Reduced from 80 to 75
            
            Spacer()
            
            // Flight path section - SMALLER ELEMENTS
            VStack(spacing: 4) { // Reduced from 6 to 4
                // Flight path visualization
                HStack(spacing: 0) {
                    // Left circle
                    Circle()
                        .stroke(Color.black.opacity(0.6), lineWidth: 1)
                        .frame(width: 6, height: 6) // Reduced from 6 to 5
                    
                    // Left line segment
                    Rectangle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width:12,height: 1)
                       
                    
                    // Date/Time capsule in the middle
                    Text(duration)
                        .font(.system(size: 11)) // Reduced from 12 to 11
                        .foregroundColor(Color.black.opacity(0.6))
                        .padding(.horizontal, 10) // Reduced from 8 to 6
                        .padding(.vertical, 1) // Reduced from 2 to 1
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black.opacity(0.6), lineWidth: 0.5)
                                )
                        )
                        .padding(.horizontal,6)
                    
                    // Right line segment
                    Rectangle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width:12,height: 1)
                        
                    
                    // Right circle
                    Circle()
                        .stroke(Color.black.opacity(0.6), lineWidth: 1)
                        .frame(width: 6, height: 6) // Reduced from 6 to 5
                }
                .frame(width: 116) // Reduced from 120 to 110
                
                // Direct/Stops indicator - SMALLER BADGES
                if isDirect {
                    Text("Direct")
                        .font(.system(size: 10, weight: .medium)) // Reduced from 11 to 10
                        .fontWeight(.bold)
                        .foregroundColor(Color("darkGreen"))
                        .padding(.horizontal, 6) // Reduced from 8 to 6
                        .padding(.vertical, 1) // Reduced from 2 to 1
                        
                } else {
                    Text("\(stops) Stop\(stops > 1 ? "s" : "")")
                        .font(.system(size: 10, weight: .medium)) // Reduced from 11 to 10
                        .foregroundColor(Color("darkGray"))
                        .padding(.horizontal, 6) // Reduced from 8 to 6
                        .padding(.vertical, 1) // Reduced from 2 to 1
                }
            }
            
            Spacer()
            
            // Arrival section - TIGHTER SPACING
            VStack(alignment: .trailing, spacing: 2) { // Reduced from 4 to 2
                Text(arrivalTime)
                    .font(.system(size: 16, weight: .semibold)) // Reduced from 18 to 16
                    .foregroundColor(.black)
                
                // Arrival code and date in the same row (HStack)
                HStack(spacing: 4) { // Reduced from 8 to 6
                    Text(arrivalCode)
                        .font(.system(size: 13)) // Reduced from 14 to 13
                        .foregroundColor(.gray)
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 4, height: 4)
                    Text(arrivalDate)
                        .font(.system(size: 11)) // Reduced from 12 to 11
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 80, alignment: .trailing) // Reduced from 80 to 75
        }
    }
}




struct FlightDetailCard: View {
    let destination: String
    let isDirectFlight: Bool
    let flightDuration: String
    let flightClass: String
    
    // For direct flights
    let departureDate: String
    let departureTime: String? // Added time separately
    let departureAirportCode: String
    let departureAirportName: String
    let departureTerminal: String
    
    let airline: String
    let flightNumber: String
    let airlineLogo: String // Add this property
    
    let arrivalDate: String
    let arrivalTime: String? // Added time separately
    let arrivalAirportCode: String
    let arrivalAirportName: String
    let arrivalTerminal: String
    let arrivalNextDay: Bool // Flag to show "You will reach the next day"
    
    // For connecting flights
    let connectionSegments: [ConnectionSegment]?
    
    // Initialize for direct flights
    init(
        destination: String,
        isDirectFlight: Bool,
        flightDuration: String,
        flightClass: String,
        departureDate: String,
        departureTime: String? = nil,
        departureAirportCode: String,
        departureAirportName: String,
        departureTerminal: String,
        airline: String,
        flightNumber: String,
        airlineLogo: String, // Add this parameter
        arrivalDate: String,
        arrivalTime: String? = nil,
        arrivalAirportCode: String,
        arrivalAirportName: String,
        arrivalTerminal: String,
        arrivalNextDay: Bool = false
    ) {
        self.destination = destination
        self.isDirectFlight = isDirectFlight
        self.flightDuration = flightDuration
        self.flightClass = flightClass
        self.departureDate = departureDate
        self.departureTime = departureTime
        self.departureAirportCode = departureAirportCode
        self.departureAirportName = departureAirportName
        self.departureTerminal = departureTerminal
        self.airline = airline
        self.flightNumber = flightNumber
        self.airlineLogo = airlineLogo // Initialize this property
        self.arrivalDate = arrivalDate
        self.arrivalTime = arrivalTime
        self.arrivalAirportCode = arrivalAirportCode
        self.arrivalAirportName = arrivalAirportName
        self.arrivalTerminal = arrivalTerminal
        self.arrivalNextDay = arrivalNextDay
        self.connectionSegments = nil
    }
    
    // Initialize for connecting flights
    init(
        destination: String,
        flightDuration: String,
        flightClass: String,
        connectionSegments: [ConnectionSegment]
    ) {
        self.destination = destination
        self.isDirectFlight = false
        self.flightDuration = flightDuration
        self.flightClass = flightClass
        self.departureDate = ""
        self.departureTime = nil
        self.departureAirportCode = ""
        self.departureAirportName = ""
        self.departureTerminal = ""
        self.airline = ""
        self.flightNumber = ""
        self.airlineLogo = "" // Initialize this property for connecting flights
        self.arrivalDate = ""
        self.arrivalTime = nil
        self.arrivalAirportCode = ""
        self.arrivalAirportName = ""
        self.arrivalTerminal = ""
        self.arrivalNextDay = false
        self.connectionSegments = connectionSegments
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header section
            VStack(alignment: .leading, spacing: 15) {
                Text("Flight to \(destination)")
                    .font(.system(size: 18, weight: .bold))
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Text(isDirectFlight ? "Direct" : "\((connectionSegments?.count ?? 1) - 1) Stop")

                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isDirectFlight ? .green : .primary)
                    }
                    
                    Text("|").opacity(0.5)
                    
                    HStack(spacing: 4) {
                        Text(flightDuration)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Text("|").opacity(0.5)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "carseat.right.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(flightClass)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
            .padding(.horizontal, 16)
            
            if isDirectFlight {
                // Direct flight path visualization
                DirectFlightView(
                    departureDate: departureDate,
                    departureTime: departureTime,
                    departureAirportCode: departureAirportCode,
                    departureAirportName: departureAirportName,
                    departureTerminal: departureTerminal,
                    airline: airline,
                    flightNumber: flightNumber,
                    airlineLogo: airlineLogo, // Pass the airline logo
                    arrivalDate: arrivalDate,
                    arrivalTime: arrivalTime,
                    arrivalAirportCode: arrivalAirportCode,
                    arrivalAirportName: arrivalAirportName,
                    arrivalTerminal: arrivalTerminal,
                    arrivalNextDay: arrivalNextDay
                )
            } else if let segments = connectionSegments {
                // Connecting flight path visualization
                ConnectingFlightView(segments: segments)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct DirectFlightView: View {
    let departureDate: String
    let departureTime: String?
    let departureAirportCode: String
    let departureAirportName: String
    let departureTerminal: String
    
    let airline: String
    let flightNumber: String
    let airlineLogo: String
    
    let arrivalDate: String
    let arrivalTime: String?
    let arrivalAirportCode: String
    let arrivalAirportName: String
    let arrivalTerminal: String
    let arrivalNextDay: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline positioned to align with airport codes - UPDATED alignment
            VStack(spacing: 0) {
                // UPDATED: Slightly moved down for perfect alignment
                Spacer()
                    .frame(height: 42) // Increased from 35 to 42 to move timeline down
                
                // Departure circle
                Circle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 8, height: 8)
                
                // Connecting line - UPDATED: Reduced straight line height
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 1, height: 130) // Reduced from 155 to 130
                    .padding(.top, 4) // Reduced from 6 to 4
                    .padding(.bottom, 4) // Reduced from 6 to 4
                
                // Arrival circle
                Circle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 8, height: 8)
                
                // Space for remaining content
                Spacer()
            }
            
            // Flight details with proper spacing
            VStack(alignment: .leading, spacing: 32) { // Good spacing between sections
                
                // DEPARTURE SECTION
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Text(departureDate)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                        
                        if let time = departureTime {
                            Text(time)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                    
                    HStack(alignment: .center, spacing: 12) {
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 40, height: 32)
                                .cornerRadius(4)
                            Text(departureAirportCode)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(departureAirportName)
                                .font(.system(size: 14, weight: .medium))
                            Text("Terminal \(departureTerminal)")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                }
                
                // AIRLINE SECTION - Centered between departure and arrival
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: airlineLogo)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 36, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        case .failure(_), .empty:
                            // Fallback with airline initials
                            ZStack {
                                Rectangle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 36, height: 32)
                                    .cornerRadius(4)
                                
                                Text(String(airline.prefix(2)))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                        @unknown default:
                            // Default placeholder
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 36, height: 32)
                                    .cornerRadius(4)
                                
                                Image(systemName: "airplane")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(airline)
                            .font(.system(size: 14))
                        Text(flightNumber)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
                // ARRIVAL SECTION
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Text(arrivalDate)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            
                        if let time = arrivalTime {
                            Text(time)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                        
                        if arrivalNextDay {
                            Text("You will reach the next day")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                    }
                    
                    HStack(alignment: .center, spacing: 12) {
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 40, height: 32)
                                .cornerRadius(4)
                            Text(arrivalAirportCode)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(arrivalAirportName)
                                .font(.system(size: 14, weight: .medium))
                            Text("Terminal \(arrivalTerminal)")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .padding(.leading, 16)
    }
}

// Updated ConnectionSegment model with airline logo support
struct ConnectionSegment: Identifiable {
    let id = UUID()
    
    // Departure info
    let departureDate: String
    let departureTime: String
    let departureAirportCode: String
    let departureAirportName: String
    let departureTerminal: String
    
    // Arrival info
    let arrivalDate: String
    let arrivalTime: String
    let arrivalAirportCode: String
    let arrivalAirportName: String
    let arrivalTerminal: String
    let arrivalNextDay: Bool
    
    // Flight info
    let airline: String
    let flightNumber: String
    let airlineLogo: String // Added airline logo URL
    
    // Connection info (if not the last segment)
    let connectionDuration: String? // e.g. "2h 50m connection"
}

struct ConnectingFlightView: View {
    let segments: [ConnectionSegment]
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline positioned to align with airport codes - UPDATED alignment
            VStack(spacing: 0) {
                // UPDATED: Slightly moved down for perfect alignment
                Spacer()
                    .frame(height: 42) // Increased from 35 to 42 to move timeline down
                
                // First departure circle
                Circle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 8, height: 8)
                
                // For each segment, create connecting elements
                ForEach(0..<segments.count, id: \.self) { index in
                    // Solid line for flight segment - UPDATED: Reduced straight line height
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 1, height: 150) // Reduced from 190 to 150
                        .padding(.top, 4) // Reduced from 6 to 4
                        .padding(.bottom, 4) // Reduced from 6 to 4
                    
                    // Connection point (if not the last segment)
                    if index < segments.count - 1 {
                        Circle()
                            .stroke(Color.primary, lineWidth: 1)
                            .frame(width: 8, height: 8)
                        
                        // Dotted line for layover/connection - KEPT same height
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 1, height: 130) // Kept at 130 (dotted line unchanged)
                            .overlay(
                                Path { path in
                                    path.move(to: CGPoint(x: 0.5, y: 0))
                                    path.addLine(to: CGPoint(x: 0.5, y: 130)) // Kept path height at 130
                                }
                                .stroke(Color.primary, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                            )
                            .padding(.top, 4) // Reduced from 6 to 4
                            .padding(.bottom, 4) // Reduced from 6 to 4
                        
                        Circle()
                            .stroke(Color.primary, lineWidth: 1)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Final arrival circle
                Circle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 8, height: 8)
                
                // Space for remaining content
                Spacer()
            }
            
            // Flight details with proper spacing matching DirectFlightView
            VStack(alignment: .leading, spacing: 32) {
                ForEach(0..<segments.count, id: \.self) { segmentIndex in
                    let segment = segments[segmentIndex]
                    
                    // DEPARTURE SECTION
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text(segment.departureDate)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            
                            Text(segment.departureTime)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                        
                        HStack(alignment: .center, spacing: 12) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 40, height: 32)
                                    .cornerRadius(4)
                                Text(segment.departureAirportCode)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(segment.departureAirportName)
                                    .font(.system(size: 14, weight: .medium))
                                Text("Terminal \(segment.departureTerminal)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // AIRLINE SECTION
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: segment.airlineLogo)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 36, height: 32)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            case .failure(_), .empty:
                                // Fallback with airline initials
                                ZStack {
                                    Rectangle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 36, height: 32)
                                        .cornerRadius(4)
                                    
                                    Text(String(segment.airline.prefix(2)))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.blue)
                                }
                            @unknown default:
                                // Default placeholder
                                ZStack {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 36, height: 32)
                                        .cornerRadius(4)
                                    
                                    Image(systemName: "airplane")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(segment.airline)
                                .font(.system(size: 14))
                            Text(segment.flightNumber)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    // ARRIVAL SECTION
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text(segment.arrivalDate)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                
                            Text(segment.arrivalTime)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                            
                            if segment.arrivalNextDay {
                                Text("You will reach the next day")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        HStack(alignment: .center, spacing: 12) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 40, height: 32)
                                    .cornerRadius(4)
                                Text(segment.arrivalAirportCode)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(segment.arrivalAirportName)
                                    .font(.system(size: 14, weight: .medium))
                                Text("Terminal \(segment.arrivalTerminal)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Show connection info if there is a next segment
                    if let connectionDuration = segment.connectionDuration {
                        HStack {
                            Spacer()
                                .frame(width: 40)
                            
                            Text(connectionDuration)
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.red, lineWidth: 1)
                                        .background(Color.red.opacity(0.1))
                                )
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .padding(.leading, 16)
    }
}

// Helper view for creating dotted lines
struct DottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

struct FilterButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 14))
                Text("Filter")
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
        .foregroundColor(.primary)
    }
}

struct FlightFilterTabView: View {
    @State private var tabPressStates: [Bool] = Array(repeating: false, count: FilterOption.allCases.count)
    let selectedFilter: FilterOption
    let onSelectFilter: (FilterOption) -> Void
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case best = "Best"
        case cheapest = "Cheapest"
        case fastest = "Fastest"
        case direct = "Direct"
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(FilterOption.allCases.enumerated()), id: \.element) { index, filter in
                    Button(action: {
                        // Haptic feedback
                        let selectionFeedback = UISelectionFeedbackGenerator()
                        selectionFeedback.selectionChanged()
                        
                        // Tab press animation
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            tabPressStates[index] = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                tabPressStates[index] = false
                            }
                        }
                        
                        onSelectFilter(filter)
                    }) {
                        Text(filter.rawValue)
                            .font(.system(size: 14, weight: selectedFilter == filter ? .semibold : .regular))
                            .foregroundColor(selectedFilter == filter ? .blue : .black)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedFilter == filter ? Color.blue : Color.black.opacity(0.3), lineWidth: selectedFilter == filter ? 1 : 0.5)
                            )
                            .scaleEffect(tabPressStates[index] ? 0.95 : 1.0)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}


struct ModifiedDetailedFlightListView: View {
    let externalIsCollapsed: Binding<Bool>?
        @State private var internalIsCollapsed = false
        
        // Computed property to get the right binding
        private var isCollapsedBinding: Binding<Bool> {
            externalIsCollapsed ?? $internalIsCollapsed
        }
        
        // Simple initializer
        init(viewModel: ExploreViewModel, isCollapsed: Binding<Bool>? = nil) {
            self.viewModel = viewModel
            self.externalIsCollapsed = isCollapsed
        }
       
    @State private var skeletonOpacity: Double = 0
    @State private var skeletonOffset: CGFloat = 20
    @ObservedObject var viewModel: ExploreViewModel
    @State private var selectedFilter: FlightFilterTabView.FilterOption = .all
    @State private var filteredResults: [FlightDetailResult] = []
    @State private var showingFilterSheet = false
    @State private var hasAppliedInitialDirectFilter = false
    @State private var showingFlightDetails = false
    
    @State private var showingLoadingSkeletons = true
    @State private var hasReceivedEmptyResults = false
    
    // Auto-retry mechanism
    @State private var retryCount = 0
    @State private var retryTimer: Timer? = nil
    @State private var lastDataTimestamp = Date()
    
    // Simplified loading state management with Equatable
    @State private var viewState: ViewState = .loading
    
    enum ViewState: Equatable {
        case loading
        case loaded
        case error(String)
        case empty
        
        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading): return true
            case (.loaded, .loaded): return true
            case (.empty, .empty): return true
            case (.error(let lhsMsg), .error(let rhsMsg)): return lhsMsg == rhsMsg
            default: return false
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Flights to \(viewModel.toLocation)")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                Spacer()
            }
            .background(Color("scroll"))
            // Filter tabs section
            HStack {
                FilterButton {
                    showingFilterSheet = true
                }
                .padding(.leading, 20)
                
                FlightFilterTabView(
                    selectedFilter: selectedFilter,
                    onSelectFilter: { filter in
                        selectedFilter = filter
                        applyQuickFilterOption(filter)
                    }
                )
            }
            .padding(.trailing, 16)
            .padding(.vertical, 8)
            .background(Color("scroll"))
            
            // Flight count display - UPDATED: Always show count when available
            if viewModel.totalFlightCount > 0 || !filteredResults.isEmpty {
                HStack {
                    let displayCount = viewModel.totalFlightCount > 0 ? viewModel.totalFlightCount : filteredResults.count
                    Text("\(displayCount) flights found")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(8)
                .background(Color("scroll"))
            }
            
            
            ZStack {
                // Background color for the entire content area
                Color("scroll").edgesIgnoringSafeArea(.all)
                
                if case .loading = viewState {
                    VStack {
                        Spacer()
                        ForEach(0..<4, id: \.self) { index in
                            DetailedFlightCardSkeleton()
                                .padding(.bottom, 5)
                                .opacity(skeletonOpacity)
                                .offset(y: skeletonOffset)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.1),
                                    value: skeletonOpacity
                                )
                                .collapseSearchCardOnDrag(isCollapsed: isCollapsedBinding) // ADD THIS
                        }
                        .padding(.top,36)
                        Spacer()
                    }
                    .onAppear {
                        withAnimation {
                            skeletonOpacity = 1.0
                            skeletonOffset = 0
                        }
                    }
                } else if case .error(let message) = viewState {
                    VStack {
                        Spacer()
                        Text("Error: \(message)")
                            .foregroundColor(.red)
                            .padding()
                        Button("Retry") {
                            retrySearch()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        Spacer()
                    }
                    .collapseSearchCardOnDrag(isCollapsed: isCollapsedBinding) // ADD THIS
                } else if filteredResults.isEmpty && !viewModel.isLoadingDetailedFlights {
                    // Show empty state only when we're certain there are no results
                    VStack {
                        Spacer()
                        Text("No flights found with current filters")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button("Clear Filters") {
                            clearAllFilters()
                        }
                        .padding(.top, 16)
                        .foregroundColor(.blue)
                        
                        Spacer()
                    }
                    .collapseSearchCardOnDrag(isCollapsed: isCollapsedBinding) // ADD THIS
                } else if !filteredResults.isEmpty {
                    // Show flight list when we have results
                    PaginatedFlightList(
                        viewModel: viewModel,
                        filteredResults: filteredResults,
                        isMultiCity: isMultiCity,
                        onFlightSelected: { result in
                            viewModel.selectedFlightId = result.id
                            showingFlightDetails = true
                        }
                    )
                    .collapseSearchCardOnDrag(isCollapsed: isCollapsedBinding) // ADD THIS
                    .onAppear {
                        cancelRetryTimer()
                        hasReceivedEmptyResults = false
                    }
                } else {
                    // Show skeleton loading while processing
                    VStack {
                        Spacer()
                        ForEach(0..<4, id: \.self) { _ in
                            DetailedFlightCardSkeleton()
                                .padding(.bottom, 5)
                                .collapseSearchCardOnDrag(isCollapsed: isCollapsedBinding) // ADD THIS
                        }
                        .padding(.top,36)
                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            FlightFilterSheet(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showingFlightDetails) {
            if let selectedId = viewModel.selectedFlightId,
               let selectedFlight = viewModel.detailedFlightResults.first(where: { $0.id == selectedId }) {
                FlightDetailsView(
                    selectedFlight: selectedFlight,
                    viewModel: viewModel
                )
            }
        }
        .onAppear {
            print("📱 ModifiedDetailedFlightListView appeared")
            
            initiateSearch()
            startRetryTimer()
        }
        .onDisappear {
            cancelRetryTimer()
        }
        // UPDATED: Better handling of detailedFlightResults changes
        .onReceive(viewModel.$detailedFlightResults) { newResults in
            print("📱 Received \(newResults.count) results from viewModel")
            handleNewResults(newResults)
        }
        .onReceive(viewModel.$isLoadingDetailedFlights) { isLoading in
            print("📱 Loading state changed: \(isLoading)")
            handleLoadingStateChange(isLoading)
        }
        .onReceive(viewModel.$selectedFlightId) { newValue in
            showingFlightDetails = newValue != nil
        }
        // UPDATED: Listen for total count changes to update UI
        .onReceive(viewModel.$totalFlightCount) { newCount in
            print("📱 Total flight count updated: \(newCount)")
            if newCount > 0 && filteredResults.isEmpty && !viewModel.isLoadingDetailedFlights {
                // We have a count but no results yet - this might be from a filter update
                viewState = .loading
            }
        }
    }
    
    // MARK: - Event Handlers
    
    private func handleNewResults(_ newResults: [FlightDetailResult]) {
        if !newResults.isEmpty {
            hasReceivedEmptyResults = false
            viewModel.debugDuplicateFlightIDs()
            updateFilteredResults(newResults)
            cancelRetryTimer()
            viewState = .loaded
        } else if !viewModel.isLoadingDetailedFlights && viewModel.isDataCached {
            hasReceivedEmptyResults = true
            filteredResults = []
            viewState = .empty
        }
    }
    
    private func handleLoadingStateChange(_ isLoading: Bool) {
        if isLoading {
            viewState = .loading
            return
        }
        
        // Loading finished
        if !viewModel.detailedFlightResults.isEmpty {
            hasReceivedEmptyResults = false
            viewState = .loaded
            updateFilteredResults(viewModel.detailedFlightResults)
            cancelRetryTimer()
        } else if let error = viewModel.detailedFlightError, !error.isEmpty {
            viewState = .error(error)
            filteredResults = []
            startRetryTimer()
        } else if viewModel.detailedFlightResults.isEmpty && viewModel.isDataCached {
            hasReceivedEmptyResults = true
            filteredResults = []
            viewState = .empty
        }
    }
    
    // MARK: - Filter Management
    
    private func updateFilteredResults(_ results: [FlightDetailResult]) {
        // UPDATED: Always use the results directly since filtering is done server-side
        filteredResults = results
        print("📱 Updated filtered results: \(filteredResults.count) flights")
    }
    
    private func applyQuickFilterOption(_ filter: FlightFilterTabView.FilterOption) {
        print("🔧 Applying quick filter: \(filter.rawValue)")
        
        // Create filter request based on the selected quick filter
        var filterRequest: FlightFilterRequest? = nil
        
        switch filter {
        case .all:
            // Clear all filters
            filterRequest = FlightFilterRequest()
        case .best:
            // For "best", don't set any sort parameter
            filterRequest = FlightFilterRequest()
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
    
    private func clearAllFilters() {
        print("🧹 Clearing all filters")
        selectedFilter = .all
        let emptyFilter = FlightFilterRequest()
        viewModel.applyPollFilters(filterRequest: emptyFilter)
    }
    
    // MARK: - Search Management
    
    private func retrySearch() {
        print("🔄 Retrying search")
        viewState = .loading
        
        if !viewModel.detailedFlightResults.isEmpty {
            print("Using \(viewModel.detailedFlightResults.count) existing results")
            updateFilteredResults(viewModel.detailedFlightResults)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewState = .loaded
            }
        } else if viewModel.currentSearchId != nil {
            print("Re-polling with existing search ID")
            let filterRequest = viewModel.currentFilterRequest ?? FlightFilterRequest()
            viewModel.applyPollFilters(filterRequest: filterRequest)
        } else {
            print("Starting fresh search")
            initiateSearch()
        }
    }
    
    private func initiateSearch() {
        print("🚀 Initiating search")
        viewState = .loading
        
        if !viewModel.isLoadingDetailedFlights {
            let filterRequest = FlightFilterRequest()
            viewModel.applyPollFilters(filterRequest: filterRequest)
        } else if !viewModel.detailedFlightResults.isEmpty {
            print("Using existing \(viewModel.detailedFlightResults.count) results")
            updateFilteredResults(viewModel.detailedFlightResults)
        }
    }
    
    // MARK: - Auto Retry Methods
    
    private func startRetryTimer() {
        cancelRetryTimer()
        
        if retryCount < 5 {
            print("⏰ Starting retry timer (attempt \(retryCount + 1))")
            retryTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                let timeSinceLastData = Date().timeIntervalSince(lastDataTimestamp)
                let dataIsStale = timeSinceLastData > 3.0
                
                if dataIsStale && !viewModel.isLoadingDetailedFlights {
                    print("🔄 Auto-retry triggered (attempt \(retryCount + 1))")
                    retryCount += 1
                    retrySearch()
                }
                
                if retryCount < 5 {
                    startRetryTimer()
                } else {
                    print("❌ Max retry attempts reached (\(retryCount))")
                }
            }
        }
    }
    
    private func cancelRetryTimer() {
        retryTimer?.invalidate()
        retryTimer = nil
    }
    
    // MARK: - Helper Methods
    
    private var isMultiCity: Bool {
        return viewModel.multiCityTrips.count >= 2
    }
    
    private func applyInitialDirectFilterIfNeeded() {
        if viewModel.directFlightsOnlyFromHome && !hasAppliedInitialDirectFilter {
            print("🎯 Applying initial direct filter")
            selectedFilter = .direct
            hasAppliedInitialDirectFilter = true
        }
    }
}




// Also update the ModernMultiCityFlightCardWrapper to include airline logos
struct ModernMultiCityFlightCardWrapper: View {
    let result: FlightDetailResult
    @ObservedObject var viewModel: ExploreViewModel
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Tags at the top inside the card
                if result.isBest || result.isCheapest || result.isFastest {
                    HStack(spacing: 6) {
                        if result.isBest {
                            TagView(text: "Best", color: .blue)
                        }
                        if result.isCheapest {
                            TagView(text: "Cheapest", color: .green)
                        }
                        if result.isFastest {
                            TagView(text: "Fastest", color: .purple)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
                
                // Display each leg
                ForEach(0..<result.legs.count, id: \.self) { index in
                    let leg = result.legs[index]
                    
                    if index > 0 {
                        Divider()
                            .padding(.horizontal, 16)
                    }
 
                    // Flight leg details with airline logo
                    if let segment = leg.segments.first {
                        HStack(alignment: .center, spacing: 12) {
                            // Airline logo
                            AsyncImage(url: URL(string: segment.airlineLogo)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                case .failure(_), .empty:
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.blue.opacity(0.1))
                                            .frame(width: 24, height: 24)
                                        
                                        Text(String(segment.airlineIata.prefix(1)))
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.blue)
                                    }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                            // Flight details
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(formatTime(from: segment.departureTimeAirport))
                                            .font(.system(size: 16, weight: .semibold))
                                        HStack(spacing: 4) {
                                            Text(segment.originCode)
                                                .font(.system(size: 12, weight: .medium))
                                            Text(formatDateShort(from: segment.departureTimeAirport))
                                                .font(.system(size: 10))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Duration and direct info
                                    VStack(spacing: 2) {
                                        Text(formatDuration(minutes: leg.duration))
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
                                        
                                        if leg.stopCount == 0 {
                                            Text("Direct")
                                                .font(.system(size: 9, weight: .medium))
                                                .foregroundColor(.green)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 1)
                                                .background(Color.green.opacity(0.1))
                                                .cornerRadius(3)
                                        } else {
                                            Text("\(leg.stopCount) Stop\(leg.stopCount > 1 ? "s" : "")")
                                                .font(.system(size: 9, weight: .medium))
                                                .foregroundColor(.orange)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 1)
                                                .background(Color.orange.opacity(0.1))
                                                .cornerRadius(3)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(formatTime(from: segment.arriveTimeAirport))
                                            .font(.system(size: 16, weight: .semibold))
                                        HStack(spacing: 4) {
                                            Text(formatDateShort(from: segment.arriveTimeAirport))
                                                .font(.system(size: 10))
                                                .foregroundColor(.gray)
                                            Text(segment.destinationCode)
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                }
                
                Divider()
                    .padding(.horizontal, 16)
                
                // Price and total duration
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total Duration: \(formatDuration(minutes: result.totalDuration))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Text("₹\(Int(result.minPrice))")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("For \(viewModel.adultsCount + viewModel.childrenCount) People ₹\(Int(result.minPrice * Double(viewModel.adultsCount + viewModel.childrenCount)))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper functions for formatting
    private func formatTime(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDateShort(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}


struct FlightTagView: View {
    let tag: FlightTag
    
    var body: some View {
        Text(tag.title)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tag.color)
            .cornerRadius(4)
          
    }
}

struct PriceSection: View {
    let price: String
    let passengers: String
    
    var body: some View {
        VStack(spacing: 16) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Price")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(price)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(passengers) passengers")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    // Book flight action
                }) {
                    Text("Book Flight")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }
        }
    }
}


// MARK: - Enhanced Detailed Flight Card Skeleton
struct DetailedFlightCardSkeleton: View {
    var body: some View {
        EnhancedDetailedFlightCardSkeleton()
    }
}



struct FlightFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ExploreViewModel
    
    // Sort options
    @State private var sortOption: SortOption = .best
    @State private var hasSortChanged = false
    
    // Stop filters
    @State private var directFlightsSelected = true
    @State private var oneStopSelected = false
    @State private var multiStopSelected = false
    @State private var hasStopsChanged = false
    
    // Price range
    @State private var priceRange: [Double] = [0.0, 2000.0]
    @State private var hasPriceChanged = false
    
    // Time range sliders
    @State private var departureTimes = [0.0, 24.0]
    @State private var arrivalTimes = [0.0, 24.0]
    @State private var hasTimesChanged = false
    
    // Duration slider
    @State private var durationRange = [1.75, 8.5]
    @State private var hasDurationChanged = false
    
    // Airlines - populated from API response
    @State private var selectedAirlines: Set<String> = []
    @State private var hasAirlinesChanged = false
    @State private var availableAirlines: [(name: String, code: String, logo: String)] = []
    
    // Live preview functionality
    @State private var previewFlightCount: Int = 0
    @State private var isLoadingPreview = false
    @State private var lastPreviewRequest: FlightFilterRequest?
    @State private var previewTimer: Timer?
    
    enum SortOption: String, CaseIterable {
        case best = "Best"
        case cheapest = "Cheapest"
        case fastest = "Fastest"
        case outboundTakeOff = "Outbound Take Off Time"
        case outboundLanding = "Outbound Landing Time"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Sort options section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sort")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ForEach(SortOption.allCases, id: \.self) { option in
                            HStack {
                                Text(option.rawValue)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: sortOption == option ? "inset.filled.square" : "square")
                                    .foregroundColor(sortOption == option ? .blue : .gray)
                                    .onTapGesture {
                                        sortOption = option
                                        hasSortChanged = true
                                        triggerPreviewUpdate()
                                    }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Stops section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Stops")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        stopFilterRow(
                            title: "Direct flights",
                            subtitle: "From ₹3200",
                            isSelected: directFlightsSelected
                        ) {
                            directFlightsSelected.toggle()
                            hasStopsChanged = true
                            triggerPreviewUpdate()
                        }
                        
                        stopFilterRow(
                            title: "1 Stop",
                            subtitle: "From ₹2800",
                            isSelected: oneStopSelected
                        ) {
                            oneStopSelected.toggle()
                            hasStopsChanged = true
                            triggerPreviewUpdate()
                        }
                        
                        stopFilterRow(
                            title: "2+ Stops",
                            subtitle: "From ₹2400",
                            isSelected: multiStopSelected
                        ) {
                            multiStopSelected.toggle()
                            hasStopsChanged = true
                            triggerPreviewUpdate()
                        }
                    }
                    
                    Divider()
                    
                   
                    // Price range section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Price Range")
                            .font(.headline)
                        
                        Text("\(formatPrice(priceRange[0])) - \(formatPrice(priceRange[1]))")
                            .foregroundColor(.primary)
                        
                        RangeSliderView(
                            values: $priceRange,
                            minValue: getApiMinPrice(),
                            maxValue: getApiMaxPrice(),
                            onChangeHandler: {
                                hasPriceChanged = true
                                triggerPreviewUpdate()
                            }
                        )
                        
                        HStack {
                            Text(formatPrice(getApiMinPrice()))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(formatPrice(getApiMaxPrice()))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Divider()
                    
                    // Times section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Times")
                            .font(.headline)
                        
                        Text("\(viewModel.selectedOriginCode) - \(viewModel.selectedDestinationCode)")
                            .foregroundColor(.gray)
                        
                        // Departure time slider
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Departure")
                                .foregroundColor(.primary)
                            
                            RangeSliderView(values: $departureTimes, minValue: 0, maxValue: 24, onChangeHandler: {
                                hasTimesChanged = true
                                triggerPreviewUpdate()
                            })
                            
                            HStack {
                                Text(formatTime(hours: Int(departureTimes[0])))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text(formatTime(hours: Int(departureTimes[1])))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Arrival time slider
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Arrival")
                                .foregroundColor(.primary)
                            
                            RangeSliderView(values: $arrivalTimes, minValue: 0, maxValue: 24, onChangeHandler: {
                                hasTimesChanged = true
                                triggerPreviewUpdate()
                            })
                            
                            HStack {
                                Text(formatTime(hours: Int(arrivalTimes[0])))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text(formatTime(hours: Int(arrivalTimes[1])))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Duration section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Journey Duration")
                            .font(.headline)
                        
                        Text("\(formatDuration(hours: durationRange[0])) - \(formatDuration(hours: durationRange[1]))")
                            .foregroundColor(.primary)
                        
                        RangeSliderView(values: $durationRange, minValue: 1, maxValue: 8.5, onChangeHandler: {
                            hasDurationChanged = true
                            triggerPreviewUpdate()
                        })
                        
                        HStack {
                            Text(formatDuration(hours: durationRange[0]))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(formatDuration(hours: durationRange[1]))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Divider()
                    
                    // Airlines section
                    if !availableAirlines.isEmpty {
                        airlinesSection
                    }
                }
                .padding()
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear all") {
                        resetFilters()
                    }
                    .foregroundColor(.blue)
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Enhanced Apply button with live count
                    
                    Button(action: {
                        applyFilters()
                    }) {
                        HStack {
                            Text("Apply Filters")
                                .fontWeight(.medium)
                            if isLoadingPreview {

                                    ProgressView()
                                        .scaleEffect(0.8)

                                        .foregroundColor(.white)

                            }
                            else if previewFlightCount > 0 && !isLoadingPreview {
                                Text("(\(previewFlightCount))")
                                    .fontWeight(.medium)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                        .padding()
                    }
              
            }
        }
        .onAppear {
            populateAirlinesFromResults()
            initializePriceRange()
            loadFilterStateFromViewModel()
            // Set initial preview count
            previewFlightCount = viewModel.totalFlightCount
        }
        .onDisappear {
            // Cancel any pending preview requests
            previewTimer?.invalidate()
        }
    }
    
    // MARK: - UI Helper Views
    
    @ViewBuilder
    private func stopFilterRow(title: String, subtitle: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                .foregroundColor(isSelected ? .blue : .gray)
                .onTapGesture(perform: action)
        }
    }
    
    private var airlinesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Airlines")
                    .font(.headline)
                
                Spacer()
                
                Button("Clear all") {
                    selectedAirlines.removeAll()
                    hasAirlinesChanged = true
                    triggerPreviewUpdate()
                }
                .foregroundColor(.blue)
                .font(.subheadline)
            }
            
            ForEach(availableAirlines, id: \.code) { airline in
                HStack {
                    if !airline.logo.isEmpty {
                        AsyncImage(url: URL(string: airline.logo)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            } else {
                                fallbackAirlineLogo(code: airline.code)
                            }
                        }
                    } else {
                        fallbackAirlineLogo(code: airline.code)
                    }
                    
                    Text(airline.name)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: selectedAirlines.contains(airline.code) ? "checkmark.square.fill" : "square")
                        .foregroundColor(selectedAirlines.contains(airline.code) ? .blue : .gray)
                        .onTapGesture {
                            if selectedAirlines.contains(airline.code) {
                                selectedAirlines.remove(airline.code)
                            } else {
                                selectedAirlines.insert(airline.code)
                            }
                            hasAirlinesChanged = true
                            triggerPreviewUpdate()
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private func fallbackAirlineLogo(code: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 24, height: 24)
            
            Text(String(code.prefix(1)))
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Live Preview Methods
    
    // MARK: - Price Range Helper Methods

    private func getApiMinPrice() -> Double {
        if let pollResponse = viewModel.lastPollResponse {
            return pollResponse.minPrice
        } else {
            return 0.0 // Fallback
        }
    }

    private func getApiMaxPrice() -> Double {
        if let pollResponse = viewModel.lastPollResponse {
            return pollResponse.maxPrice
        } else {
            return 5000.0 // Fallback
        }
    }
    
    private func triggerPreviewUpdate() {
        // Cancel existing timer
        previewTimer?.invalidate()
        
        // Only proceed if we have a search ID
        guard viewModel.currentSearchId != nil else {
            print("⚠️ No search ID available for preview update")
            return
        }
        
        // Start new timer with debounce
        previewTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { _ in
            updatePreviewCount()
        }
    }
    
    private func updatePreviewCount() {
        let filterRequest = createCurrentFilterRequest()
        
        // Don't make API call if request hasn't changed
        if let lastRequest = lastPreviewRequest,
           areFilterRequestsEqual(lastRequest, filterRequest) {
            return
        }
        
        lastPreviewRequest = filterRequest
        isLoadingPreview = true
        
        // Use the public method from viewModel
        viewModel.getFilterPreviewCount(filterRequest: filterRequest)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoadingPreview = false
                    if case .failure(let error) = completion {
                        print("Preview update error: \(error)")
                    }
                },
                receiveValue: { count in
                    self.previewFlightCount = count
                    self.isLoadingPreview = false
                }
            )
            .store(in: &viewModel.cancellables)
    }
    
    private func createCurrentFilterRequest() -> FlightFilterRequest {
        var filterRequest = FlightFilterRequest()
        
        // Add sort options if changed
        if hasSortChanged {
            switch sortOption {
            case .best:
                filterRequest.sortBy = nil
            case .cheapest:
                filterRequest.sortBy = "price"
                filterRequest.sortOrder = "asc"
            case .fastest:
                filterRequest.sortBy = "duration"
                filterRequest.sortOrder = "asc"
            case .outboundTakeOff:
                filterRequest.sortBy = "departure"
            case .outboundLanding:
                filterRequest.sortBy = "arrival"
            }
        }
        
        // UPDATED: Smarter API-level stop filtering + client-side filtering
        if hasStopsChanged {
            let selectedOptions = [
                (directFlightsSelected, "direct"),
                (oneStopSelected, "oneStop"),
                (multiStopSelected, "multiStop")
            ].filter { $0.0 }.map { $0.1 }
            
            print("🛑 Selected stop options: \(selectedOptions)")
            
            if selectedOptions.count == 1 {
                // Only one option selected
                if directFlightsSelected {
                    // Only direct flights - use API filtering
                    filterRequest.stopCountMax = 0
                    print("🛑 API Filter: Direct flights only (stopCountMax = 0)")
                } else if oneStopSelected {
                    // Only 1-stop flights - get up to 1 stop via API, filter out direct on client
                    filterRequest.stopCountMax = 1
                    print("🛑 API Filter: Up to 1-stop (stopCountMax = 1), client will filter out direct")
                } else if multiStopSelected {
                    // Only 2+ stops - no API limit, client will filter out 0 and 1 stop
                    print("🛑 API Filter: No limit, client will filter out direct and 1-stop")
                }
            } else if selectedOptions.count == 2 {
                // Two options selected
                if directFlightsSelected && oneStopSelected {
                    // Direct and 1-stop - use API filtering
                    filterRequest.stopCountMax = 1
                    print("🛑 API Filter: Direct and 1-stop (stopCountMax = 1)")
                } else if directFlightsSelected && multiStopSelected {
                    // Direct and 2+ stops - no API filtering, client will exclude 1-stop
                    print("🛑 API Filter: No limit, client will filter out 1-stop only")
                } else if oneStopSelected && multiStopSelected {
                    // 1-stop and 2+ stops - no API filtering, client will exclude direct
                    print("🛑 API Filter: No limit, client will filter out direct")
                }
            } else if selectedOptions.count == 3 || selectedOptions.count == 0 {
                // All options or no options - no filtering
                print("🛑 API Filter: No stop filtering")
            }
        }
        
        // Add price range if changed
        if hasPriceChanged {
            filterRequest.priceMin = Int(priceRange[0])
            filterRequest.priceMax = Int(priceRange[1])
        }
        
        // Add duration if changed
        if hasDurationChanged {
            filterRequest.durationMax = Int(durationRange[1] * 60)
        }
        
        // Add time ranges if changed
        if hasTimesChanged {
            let departureMin = Int(departureTimes[0] * 3600)
            let departureMax = Int(departureTimes[1] * 3600)
            let arrivalMin = Int(arrivalTimes[0] * 3600)
            let arrivalMax = Int(arrivalTimes[1] * 3600)
            
            let timeRange = ArrivalDepartureRange(
                arrival: TimeRange(min: arrivalMin, max: arrivalMax),
                departure: TimeRange(min: departureMin, max: departureMax)
            )
            filterRequest.arrivalDepartureRanges = [timeRange]
        }
        
        // Add airline filters if changed
        if hasAirlinesChanged && !selectedAirlines.isEmpty && selectedAirlines.count < availableAirlines.count {
            filterRequest.iataCodesInclude = Array(selectedAirlines)
        }
        
        return filterRequest
    }
    
    private func areFilterRequestsEqual(_ request1: FlightFilterRequest, _ request2: FlightFilterRequest) -> Bool {
        return request1.sortBy == request2.sortBy &&
               request1.stopCountMax == request2.stopCountMax &&
               request1.priceMin == request2.priceMin &&
               request1.priceMax == request2.priceMax &&
               request1.durationMax == request2.durationMax &&
               request1.iataCodesInclude == request2.iataCodesInclude
    }
    
    // MARK: - Helper Methods
    
  
    
    private func formatTime(hours: Int) -> String {
        let hour = hours % 12 == 0 ? 12 : hours % 12
        let amPm = hours < 12 ? "am" : "pm"
        return "\(hour):00 \(amPm)"
    }
    
    private func formatDuration(hours: Double) -> String {
        let wholeHours = Int(hours)
        let minutes = Int((hours - Double(wholeHours)) * 60)
        return "\(wholeHours)h \(minutes)m"
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: price)) ?? "₹\(Int(price))"
    }
    
    private func resetFilters() {
        sortOption = .best
        hasSortChanged = false
        
        directFlightsSelected = true
        oneStopSelected = false
        multiStopSelected = false
        hasStopsChanged = false
        
        departureTimes = [0.0, 24.0]
        arrivalTimes = [0.0, 24.0]
        hasTimesChanged = false
        
        durationRange = [1.75, 8.5]
        hasDurationChanged = false
        
        selectedAirlines.removeAll()
        hasAirlinesChanged = false
        
        initializePriceRange()
        hasPriceChanged = false
        
        triggerPreviewUpdate()
    }
    
    private func populateAirlinesFromResults() {
        if let pollResponse = viewModel.lastPollResponse {
            self.availableAirlines = pollResponse.airlines.map { airline in
                return (name: airline.airlineName, code: airline.airlineIata, logo: airline.airlineLogo)
            }
            
            if !selectedAirlines.isEmpty {
                let availableCodes = Set(availableAirlines.map { $0.code })
                selectedAirlines = selectedAirlines.intersection(availableCodes)
            }
        }
    }
    
    private func initializePriceRange() {
        // Set price range based on min/max price in results
        if let pollResponse = viewModel.lastPollResponse {
            let minPrice = pollResponse.minPrice
            let maxPrice = pollResponse.maxPrice
            
            // Only update if we have valid prices and haven't been modified by user
            if minPrice > 0 && maxPrice >= minPrice && !hasPriceChanged {
                // Set initial range to full API range
                priceRange = [minPrice, maxPrice]
                print("📊 Initialized price range from API: ₹\(Int(minPrice)) - ₹\(Int(maxPrice))")
            }
        } else {
            // Fallback default range only if no API data
            if !hasPriceChanged {
                priceRange = [0.0, 5000.0]
                print("📊 Using fallback price range: ₹0 - ₹5000")
            }
        }
    }
    
    private func applyFilters() {
        let filterRequest = createCurrentFilterRequest()
        
        // Save filter state to view model
        saveFilterStateToViewModel()
        
        // Apply the filter through the API - this will update the main results
        viewModel.applyPollFilters(filterRequest: filterRequest)
        
        // Dismiss the sheet
        dismiss()
    }
    
    private func saveFilterStateToViewModel() {
        viewModel.filterSheetState.sortOption = mapSortOptionToFilterOption(sortOption)
        viewModel.filterSheetState.directFlightsSelected = directFlightsSelected
        viewModel.filterSheetState.oneStopSelected = oneStopSelected
        viewModel.filterSheetState.multiStopSelected = multiStopSelected
        viewModel.filterSheetState.priceRange = priceRange
        viewModel.filterSheetState.departureTimes = departureTimes
        viewModel.filterSheetState.arrivalTimes = arrivalTimes
        viewModel.filterSheetState.durationRange = durationRange
        viewModel.filterSheetState.selectedAirlines = selectedAirlines
    }
    
    private func loadFilterStateFromViewModel() {
        sortOption = mapFilterOptionToSortOption(viewModel.filterSheetState.sortOption)
        directFlightsSelected = viewModel.filterSheetState.directFlightsSelected
        oneStopSelected = viewModel.filterSheetState.oneStopSelected
        multiStopSelected = viewModel.filterSheetState.multiStopSelected
        
        if viewModel.filterSheetState.priceRange != [0.0, 2000.0] {
            priceRange = viewModel.filterSheetState.priceRange
        }
        
        departureTimes = viewModel.filterSheetState.departureTimes
        arrivalTimes = viewModel.filterSheetState.arrivalTimes
        durationRange = viewModel.filterSheetState.durationRange
        selectedAirlines = viewModel.filterSheetState.selectedAirlines
    }
    
    private func mapFilterOptionToSortOption(_ option: FlightFilterTabView.FilterOption) -> SortOption {
        switch option {
        case .best:
            return .best
        case .cheapest:
            return .cheapest
        case .fastest:
            return .fastest
        default:
            return .best
        }
    }
    
    private func mapSortOptionToFilterOption(_ option: SortOption) -> FlightFilterTabView.FilterOption {
        switch option {
        case .best:
            return .best
        case .cheapest:
            return .cheapest
        case .fastest:
            return .fastest
        default:
            return .best
        }
    }
}

// Updated RangeSliderView with callback for change detection
struct RangeSliderView: View {
    @Binding var values: [Double]
    let minValue: Double
    let maxValue: Double
    var onChangeHandler: (() -> Void)? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                
                // Selected Range - FIXED: Safe calculation with bounds checking
                Rectangle()
                    .fill(Color.blue)
                    .frame(
                        width: calculateRangeWidth(geometry: geometry),
                        height: 4
                    )
                    .offset(x: calculateRangeOffset(geometry: geometry))
                
                // Low Thumb - FIXED: Safe position calculation
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 2)
                    .offset(x: calculateThumbPosition(for: values[0], geometry: geometry))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newValue = calculateValueFromPosition(
                                    position: gesture.location.x,
                                    geometry: geometry
                                )
                                // Ensure low value doesn't exceed high value
                                let clampedValue = min(values[1] - 0.1, max(minValue, newValue))
                                values[0] = clampedValue
                                onChangeHandler?()
                            }
                    )
                
                // High Thumb - FIXED: Safe position calculation
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 2)
                    .offset(x: calculateThumbPosition(for: values[1], geometry: geometry))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newValue = calculateValueFromPosition(
                                    position: gesture.location.x,
                                    geometry: geometry
                                )
                                // Ensure high value doesn't go below low value
                                let clampedValue = max(values[0] + 0.1, min(maxValue, newValue))
                                values[1] = clampedValue
                                onChangeHandler?()
                            }
                    )
            }
        }
        .frame(height: 30)
    }
    
    // MARK: - Safe Calculation Methods
    
    private func calculateRangeWidth(geometry: GeometryProxy) -> CGFloat {
        guard maxValue > minValue else { return 0 }
        
        let range = values[1] - values[0]
        let totalRange = maxValue - minValue
        let ratio = range / totalRange
        
        // Clamp the width between 0 and geometry width
        let calculatedWidth = CGFloat(ratio) * geometry.size.width
        return max(0, min(calculatedWidth, geometry.size.width))
    }
    
    private func calculateRangeOffset(geometry: GeometryProxy) -> CGFloat {
        guard maxValue > minValue else { return 0 }
        
        let offsetRatio = (values[0] - minValue) / (maxValue - minValue)
        let calculatedOffset = CGFloat(offsetRatio) * geometry.size.width
        
        // Clamp the offset between 0 and geometry width
        return max(0, min(calculatedOffset, geometry.size.width))
    }
    
    private func calculateThumbPosition(for value: Double, geometry: GeometryProxy) -> CGFloat {
        guard maxValue > minValue else { return -10 } // Center the thumb
        
        let ratio = (value - minValue) / (maxValue - minValue)
        let calculatedPosition = CGFloat(ratio) * geometry.size.width - 10 // -10 to center the thumb
        
        // Clamp position to keep thumb within bounds
        return max(-10, min(calculatedPosition, geometry.size.width - 10))
    }
    
    private func calculateValueFromPosition(position: CGFloat, geometry: GeometryProxy) -> Double {
        guard maxValue > minValue, geometry.size.width > 0 else { return minValue }
        
        let ratio = max(0, min(1, position / geometry.size.width))
        return minValue + Double(ratio) * (maxValue - minValue)
    }
}


// REPLACE the existing PaginatedFlightList in ExploreComponents.swift with this corrected version:

struct PaginatedFlightList: View {
    @ObservedObject var viewModel: ExploreViewModel
    let filteredResults: [FlightDetailResult]
    let isMultiCity: Bool
    let onFlightSelected: (FlightDetailResult) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // UNIFIED: Always use DetailedFlightCardWrapper for ALL trip types
                // This ensures the same beautiful cards everywhere
                ForEach(filteredResults, id: \.id) { result in
                    DetailedFlightCardWrapper(
                        result: result,
                        viewModel: viewModel,
                        onTap: {
                            onFlightSelected(result)
                        }
                    )
                    .padding(.horizontal)
                }
                
                // Footer
                ScrollViewFooter(
                    viewModel: viewModel,
                    loadMore: {
                        viewModel.loadMoreFlights()
                    }
                )
                
                // Bottom spacer
                Spacer(minLength: 50)
            }
            .padding(.vertical)
        }
        .background(Color("scroll"))
    }
}

// Preference keys for tracking scroll state
struct ScrollViewHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


// MARK: - Good to Know Section
struct GoodToKnowSection: View {
    let originCode: String
    let destinationCode: String
    let isRoundTrip: Bool
    @State private var showingSelfTransferInfo = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Good to Know")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                // Departure/Return info
                if isRoundTrip {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                        
                        Text("You are departing from \(originCode)\n but returning to \(destinationCode)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                // Self Transfer row
                Button(action: {
                    showingSelfTransferInfo = true
                }) {
                    HStack {
                        Image(systemName: "suitcase.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                        
                        Text("Self Transfer")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
            }
        }
        .padding(.vertical)
        .background(Color(.white))
        .cornerRadius(16)
        .padding(.horizontal)
        .sheet(isPresented: $showingSelfTransferInfo) {
            SelfTransferInfoSheet()
                .presentationDetents([.fraction(0.75)])
        }
    }
}

// MARK: - Self Transfer Info Sheet
struct SelfTransferInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("Self-transfer")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Invisible spacer to center the title
                Image(systemName: "xmark")
                    .font(.system(size: 18))
                    .opacity(0)
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Main explanation text
                    Text("In a self-transfer trip, you book separate flights, and you're responsible for moving between them — including baggage, check-ins, and reaching the next gate or airport on time.")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .padding(.top, 20)
                    
                    // What You'll Need to Do section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Text("🧳")
                                .font(.system(size: 16))
                            
                            Text("What You'll Need to Do:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            bulletPoint("Collect and recheck baggage between flights.")
                            bulletPoint("Clear immigration/customs if switching countries.")
                            bulletPoint("Check in again for your next flight.")
                            bulletPoint("Leave extra time between flights — delays can affect your next journey.")
                        }
                        .padding(.leading, 22)
                    }
                    
                    // Example section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Text("📍")
                                .font(.system(size: 16))
                            
                            Text("Example:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Flight 1: New York → Paris")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                            
                            Text("Flight 2: Paris → Rome")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                        }
                        .padding(.leading, 22)
                        
                        HStack(spacing: 6) {
                            Text("✈️")
                                .font(.system(size: 14))
                            
                            Text("Once you land in Paris, you'll collect your bags, clear immigration, and check in again.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .lineSpacing(2)
                        }
                        .padding(.leading, 22)
                        .padding(.top, 8)
                    }
                    
                    // You're in control section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Text("⚠️")
                                .font(.system(size: 16))
                            
                            Text("You're in control:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("These flights aren't connected. If delayed, airlines aren't responsible for missed connections.")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .lineSpacing(2)
                            
                            Text("We recommend at least 4-6 hours between flights.")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .lineSpacing(2)
                        }
                        .padding(.leading, 22)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 1)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .lineSpacing(2)
        }
    }
}

// MARK: - Deals Section
struct DealsSection: View {
    let providers: [FlightProvider]
    let cheapestProvider: FlightProvider?
    
    // Combined state to track both URL and whether to show the sheet
    @State private var dealToShow: String? = nil
    @State private var showingAllDeals = false
    
    private var additionalDealsCount: Int {
        return max(0, providers.count - 1)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // More deals available button
            if additionalDealsCount > 0 {
                Button(action: {
                    showingAllDeals = true
                }) {
                    HStack {
                        Text("\(additionalDealsCount) more deals available")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Image(systemName: "chevron.up")
                            .foregroundColor(.blue)
                            .font(.system(size: 14))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            
            if additionalDealsCount > 0 {
                Divider()
            }
            
            // Cheapest deal section
            if let cheapest = cheapestProvider,
               let splitProvider = cheapest.splitProviders.first {
                
                HStack {
                    Text("Cheap Deal for you")
                        .font(.system(size: 16,))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                HStack {
                    Text(splitProvider.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // View Deal button
                    Button(action: {
                        // Store the URL first, then show the sheet
                        if !splitProvider.deeplink.isEmpty {
                            print("Setting URL and showing sheet: \(splitProvider.deeplink)")
                            dealToShow = splitProvider.deeplink
                        } else {
                            print("Empty URL, using fallback")
                            dealToShow = "https://google.com" // Fallback URL
                        }
                    }) {
                        Text("View Deal")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                    .buttonStyle(BorderlessButtonStyle()) // This helps with button responsiveness
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
        .padding(.bottom, 20)
        
        // Sheet for showing all deals
        .sheet(isPresented: $showingAllDeals) {
            ProviderSelectionSheet(
                providers: providers,
                onProviderSelected: { deeplink in
                    // Store the URL to show after dismissing this sheet
                    if !deeplink.isEmpty {
                        dealToShow = deeplink
                    }
                    showingAllDeals = false
                }
            )
        }
        
        // Use this technique to show the web view with a URL
        .fullScreenCover(item: Binding(
            get: { dealToShow.map { WebViewURL(url: $0) } },
            set: { newValue in dealToShow = newValue?.url }
        )) { webViewURL in
            SafariView(url: webViewURL.url)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

// Helper struct to make the URL identifiable for fullScreenCover
struct WebViewURL: Identifiable {
    let id = UUID()
    let url: String
}

// Clean SafariView that directly uses SFSafariViewController
struct SafariView: UIViewControllerRepresentable {
    let url: String
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let finalURL: URL
        
        if let validURL = URL(string: url) {
            finalURL = validURL
        } else {
            print("⚠️ Invalid URL: \(url). Using fallback.")
            finalURL = URL(string: "https://google.com")!
        }
        
        let controller = SFSafariViewController(url: finalURL)
        controller.preferredControlTintColor = UIColor.systemOrange
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // Nothing to update
    }
}


// MARK: - Provider Selection Sheet - Updated to match exact UI
struct ProviderSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let providers: [FlightProvider]
    let onProviderSelected: (String) -> Void
    
    @State private var isReadBeforeBookingExpanded = false
    
    private var sortedProviders: [SplitProvider] {
        let allProviders = providers.flatMap { $0.splitProviders }
        return allProviders.sorted { $0.price < $1.price }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("\(sortedProviders.count) providers - Price in USD")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Read Before Booking expandable section - EXACT UI MATCH
                VStack(spacing: 0) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isReadBeforeBookingExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("Read Before Booking")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                            

                            
                            Image(systemName: isReadBeforeBookingExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.blue)
                                .font(.system(size: 14))
                                .rotationEffect(.degrees(isReadBeforeBookingExpanded ? 0 : 0))
                                .animation(.easeInOut(duration: 0.3), value: isReadBeforeBookingExpanded)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    
                    if isReadBeforeBookingExpanded {
                        VStack(alignment: .leading, spacing: 16) {
                            // First paragraph - Prices information
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Prices shown always include an estimate of all mandatory taxes and charges, but remember ")
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                + Text("to check all ticket details, final prices and terms and conditions")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                + Text(" on the booking website before you book.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                            }
                            
                            // Second section - Check for extra fees
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Check for extra fees")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Some airlines / travel agencies charge extra for baggage, insurance or use of credit cards and include a service fee.")
                                        .font(.system(size: 14))
                                        .foregroundColor(.primary)
                                    
                                    Text("View airlines fees.")
                                        .font(.system(size: 14))
                                        .foregroundColor(.primary)
                                       
                                }
                            }
                            
                            // Third section - Check T&Cs for travellers aged 12-16
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Check T&Cs for travellers aged 12-16")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Restrictions may apply to young passengers travelling alone.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                
                
                // Provider list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(sortedProviders.enumerated()), id: \.element.deeplink) { index, provider in
                            ProviderRow(
                                provider: provider,
                                onSelected: {
                                    onProviderSelected(provider.deeplink)
                                    dismiss()
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .background(Color("scroll"))
            .navigationTitle("Choose Provider")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// MARK: - Provider Row
struct ProviderRow: View {
    let provider: SplitProvider
    let onSelected: () -> Void
    
    private var supportFeatures: [String] {
        var features: [String] = []
        
        // Add features based on provider rating and other criteria
        if let rating = provider.rating, rating >= 4.5 {
            features.append("24/7 Customer support")
        }
        if provider.name.lowercased().contains("cleartrip") ||
           provider.name.lowercased().contains("makemytrip") {
            features.append("Email Notifications")
            features.append("Chat Support")
        } else if provider.name.lowercased().contains("goibibo") {
            features.append("Telephone Support")
        } else {
            features.append("Phone & Email Support")
        }
        
        return features
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Provider logo
            AsyncImage(url: URL(string: provider.imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                case .failure(_), .empty:
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(provider.name.prefix(2)))
                                .font(.caption)
                                .fontWeight(.bold)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            
            // Provider info
            VStack(alignment: .leading, spacing: 4) {
                VStack(spacing:2){
                    Text(provider.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if let rating = provider.rating,
                       let ratingCount = provider.ratingCount {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 10))
                            
                            Text("\(String(format: "%.1f", rating))")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            Text("\(ratingCount)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Support features
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(supportFeatures, id: \.self) { feature in
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                                .font(.system(size: 10))
                            
                            Text(feature)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Price and button
            VStack(alignment: .trailing, spacing: 8) {
                Text("₹\(String(format: "%.2f", provider.price))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Button(action: {
                    print("View Deal button tapped for: \(provider.name)")
                    onSelected()
                }) {
                    Text("View Deal")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .cornerRadius(6)
                }
                .buttonStyle(BorderlessButtonStyle()) // Helps with responsiveness
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - WebView Sheet
struct WebViewSheet: View {
    @Environment(\.dismiss) private var dismiss
    let url: String
    
    var body: some View {
        NavigationView {
            // Check if URL is valid before trying to load it
            Group {
                if url.isEmpty {
                    VStack(spacing: 20) {
                        Text("Error: No URL provided")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Button("Close") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if URL(string: url) == nil {
                    VStack(spacing: 20) {
                        Text("Error: Invalid URL format")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(url)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                        
                        Button("Close") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    WebView(url: url)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            print("WebView loaded with URL: \(url)")
                        }
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

// MARK: - WebView
struct WebView: UIViewControllerRepresentable {
    let url: String
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        // Debug the URL before creating the view controller
        print("Creating SafariViewController with URL: \(url)")
        
        // Use a default URL if the provided one is invalid
        guard let validURL = URL(string: url), !url.isEmpty else {
            print("⚠️ Invalid URL: \(url) - using fallback")
            let fallbackURL = URL(string: "https://google.com")!
            let safariVC = SFSafariViewController(url: fallbackURL)
            safariVC.preferredControlTintColor = UIColor.systemOrange
            return safariVC
        }
        
        // Use the valid URL
        let safariVC = SFSafariViewController(url: validURL)
        safariVC.preferredControlTintColor = UIColor.systemOrange
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - Updated Price Section (Replace existing PriceSection)
struct EnhancedPriceSection: View {
    let selectedFlight: FlightDetailResult
    let viewModel: ExploreViewModel
    
    private var cheapestProvider: FlightProvider? {
        return selectedFlight.providers.min(by: { $0.price < $1.price })
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Good to Know Section
            GoodToKnowSection(
                originCode: viewModel.selectedOriginCode,
                destinationCode: viewModel.selectedDestinationCode,
                isRoundTrip: viewModel.isRoundTrip
            )
            
            // Deals Section
            DealsSection(
                providers: selectedFlight.providers,
                cheapestProvider: cheapestProvider
            )
        }
    }
}


struct FlightDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    let selectedFlight: FlightDetailResult
    let viewModel: ExploreViewModel
    @State private var showingShareSheet = false
    
    init(selectedFlight: FlightDetailResult, viewModel: ExploreViewModel) {
            self.selectedFlight = selectedFlight
            self.viewModel = viewModel

            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "homeGrad") // Use your asset color here
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Title text color
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Flight details content
                    if viewModel.multiCityTrips.count >= 2 {
                        // Multi-city flight details display
                        ForEach(0..<selectedFlight.legs.count, id: \.self) { legIndex in
                            let leg = selectedFlight.legs[legIndex]
                            

                            
                            if leg.stopCount == 0 && !leg.segments.isEmpty {
                                let segment = leg.segments.first!
                                displayDirectFlight(leg: leg, segment: segment)
                            } else if leg.stopCount > 0 && leg.segments.count > 1 {
                                displayConnectingFlight(leg: leg)
                            }
                            

                        }
                    } else {
                        // Regular flights display
                        if let outboundLeg = selectedFlight.legs.first {
                            if outboundLeg.stopCount == 0 && !outboundLeg.segments.isEmpty {
                                let segment = outboundLeg.segments.first!
                                displayDirectFlight(leg: outboundLeg, segment: segment)
                            } else if outboundLeg.stopCount > 0 && outboundLeg.segments.count > 1 {
                                displayConnectingFlight(leg: outboundLeg)
                            }
                            
                            if selectedFlight.legs.count > 1,
                               let returnLeg = selectedFlight.legs.last,
                               returnLeg.origin != outboundLeg.origin || returnLeg.destination != outboundLeg.destination {
                                
                                if returnLeg.stopCount == 0 && !returnLeg.segments.isEmpty {
                                    let segment = returnLeg.segments.first!
                                    displayDirectFlight(leg: returnLeg, segment: segment)
                                } else if returnLeg.stopCount > 0 && returnLeg.segments.count > 1 {
                                    displayConnectingFlight(leg: returnLeg)
                                }
                            }
                        }
                    }
                    
                    // Enhanced Price section with deals
                    EnhancedPriceSection(selectedFlight: selectedFlight, viewModel: viewModel)
                        .padding(.top)
                }
            }
            .navigationBarTitle("Flight Details", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    // This is equivalent to dismissing the view
                    viewModel.selectedFlightId = nil
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                },
                trailing: Button(action: {
                    showingShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
            )
            .sheet(isPresented: $showingShareSheet) {
                // Share sheet implementation
                ShareSheet(items: ["Check out this flight I found!"])
            }
            .background(Color("scroll"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Helper methods for displaying flight details
    @ViewBuilder
    private func displayDirectFlight(leg: FlightLegDetail, segment: FlightSegment) -> some View {
        FlightDetailCard(
            destination: leg.destination,
            isDirectFlight: true,
            flightDuration: formatDuration(minutes: leg.duration),
            flightClass: segment.cabinClass ?? "Economy",
            departureDate: formatDate(from: segment.departureTimeAirport),
            departureTime: formatTime(from: segment.departureTimeAirport),
            departureAirportCode: segment.originCode,
            departureAirportName: segment.origin,
            departureTerminal: "1",
            airline: segment.airlineName,
            flightNumber: segment.flightNumber,
            airlineLogo: segment.airlineLogo,
            arrivalDate: formatDate(from: segment.arriveTimeAirport),
            arrivalTime: formatTime(from: segment.arriveTimeAirport),
            arrivalAirportCode: segment.destinationCode,
            arrivalAirportName: segment.destination,
            arrivalTerminal: "2",
            arrivalNextDay: segment.arrivalDayDifference > 0
        )
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private func displayConnectingFlight(leg: FlightLegDetail) -> some View {
        let connectionSegments = createConnectionSegments(from: leg)
        
        FlightDetailCard(
            destination: leg.destination,
            flightDuration: formatDuration(minutes: leg.duration),
            flightClass: leg.segments.first?.cabinClass ?? "Economy",
            connectionSegments: connectionSegments
        )
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
    
    private func createConnectionSegments(from leg: FlightLegDetail) -> [ConnectionSegment] {
        var segments: [ConnectionSegment] = []
        
        for (index, segment) in leg.segments.enumerated() {
            var connectionDuration: String? = nil
            if index < leg.segments.count - 1 {
                let nextSegment = leg.segments[index + 1]
                let connectionMinutes = (nextSegment.departureTimeAirport - segment.arriveTimeAirport) / 60
                let hours = connectionMinutes / 60
                let mins = connectionMinutes % 60
                connectionDuration = "\(hours)h \(mins)m connection Airport"
            }
            
            segments.append(
                ConnectionSegment(
                    departureDate: formatDate(from: segment.departureTimeAirport),
                    departureTime: formatTime(from: segment.departureTimeAirport),
                    departureAirportCode: segment.originCode,
                    departureAirportName: segment.origin,
                    departureTerminal: "1",
                    arrivalDate: formatDate(from: segment.arriveTimeAirport),
                    arrivalTime: formatTime(from: segment.arriveTimeAirport),
                    arrivalAirportCode: segment.destinationCode,
                    arrivalAirportName: segment.destination,
                    arrivalTerminal: "2",
                    arrivalNextDay: segment.arrivalDayDifference > 0,
                    airline: segment.airlineName,
                    flightNumber: segment.flightNumber,
                    airlineLogo: segment.airlineLogo,
                    connectionDuration: connectionDuration
                )
            )
        }
        
        return segments
    }
    
    // Helper functions for formatting
    private func formatDate(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM"
        return formatter.string(from: date)
    }
    
    private func formatTime(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}

// Simple share sheet implementation for iOS
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}


struct ScrollViewFooter: View {
    let viewModel: ExploreViewModel
    var loadMore: () -> Void
    
    // Computed properties for better logic
    private var shouldLoadMore: Bool {
        return viewModel.hasMoreFlights && !viewModel.isLoadingMoreFlights && !viewModel.isLoadingDetailedFlights
    }
    
    private var isLoading: Bool {
        return viewModel.isLoadingMoreFlights
    }
    
    private var hasAllFlights: Bool {
        // FIXED: Only show "all flights loaded" when we truly have all flights
        return viewModel.isDataCached &&
               viewModel.actualLoadedCount >= viewModel.totalFlightCount &&
               viewModel.totalFlightCount > 0
    }
    
    private var isWaitingForBackend: Bool {
        // Backend is still processing data
        return !viewModel.isDataCached && viewModel.totalFlightCount > 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            if shouldLoadMore {
                // Trigger loading when this view becomes visible
                Color.clear
                    .preference(key: InViewKey.self, value: geometry.frame(in: .global).minY)
                    .onPreferenceChange(InViewKey.self) { value in
                        let screenHeight = UIScreen.main.bounds.height
                        if value < screenHeight + 100 {
                            print("📱 Footer in view - triggering load more")
                            loadMore()
                        }
                    }
            } else if isLoading {
                // Show loading indicator
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(1.0)
                        Text("Loading more flights...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .frame(height: 60)
            } else if isWaitingForBackend {
                // FIXED: Show waiting message when backend is still processing
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Searching for more flights...")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("(\(viewModel.actualLoadedCount) of \(viewModel.totalFlightCount)+ flights)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .frame(height: 80)
                .onAppear {
                    // Automatically try to load more after a delay when waiting for backend
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if self.isWaitingForBackend {
                            print("🔄 Auto-retry for backend data")
                            loadMore()
                        }
                    }
                }
            } else if hasAllFlights {
                // FIXED: Only show this when we genuinely have all flights
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("All flights loaded")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("(\(viewModel.actualLoadedCount) flights)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .frame(height: 60)
            } else {
                // FIXED: Show appropriate message for other states
                HStack {
                    Spacer()
                    Text("No more flights available")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(height: 60)
            }
        }
        .frame(height: 80)
    }
}

// 2. Create a preference key to track scroll position
struct InViewKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}



