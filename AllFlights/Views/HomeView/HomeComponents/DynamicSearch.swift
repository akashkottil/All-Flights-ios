import SwiftUI
import Combine
import CoreLocation

// MARK: - Enhanced Dynamic Height Search Input Component
struct EnhancedDynamicSearchInput: View {
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    let heightProgress: CGFloat
    let onSearchTap: () -> Void
    
    @State private var showingFromLocationSheet = false
    @State private var showingToLocationSheet = false
    @State private var showingCalendar = false
    @State private var showingPassengersSheet = false
    @State private var swapButtonScale: CGFloat = 1.0
    @State private var searchButtonScale: CGFloat = 1.0
    @State private var showErrorMessage = false
    
    // Multi-city editing states
    @State private var editingTripIndex = 0
    @State private var editingFromOrTo: LocationType = .from
    
    // Animation states for location swap
    @State private var swapRotationDegrees: Double = 0
    @State private var fromLocationOffset: CGFloat = 0
    @State private var toLocationOffset: CGFloat = 0
    @State private var fromLocationOpacity: Double = 1.0
    @State private var toLocationOpacity: Double = 1.0
    @State private var fromLocationScale: CGFloat = 1.0
    @State private var toLocationScale: CGFloat = 1.0
    @State private var isSwapping: Bool = false
    
    // Animation namespace for matched geometry effects
    @Namespace private var tripAnimation
    
    enum LocationType {
        case from, to
    }
    
    // Height calculations - INCREASED to match original EnhancedSearchInput
    private var baseExpandedHeight: CGFloat {
        searchViewModel.selectedTab == 2 ? 480 : 480 // Made both the same height for consistency
    }
    private var multiCityAdditionHeight: CGFloat {
        searchViewModel.selectedTab == 2 ? CGFloat(max(0, searchViewModel.multiCityTrips.count - 2) * 70) : 0
    }
    private var expandedHeight: CGFloat {
        baseExpandedHeight + multiCityAdditionHeight
    }
    private var collapsedHeight: CGFloat { 60 }
    private var currentHeight: CGFloat {
        collapsedHeight + (expandedHeight - collapsedHeight) * heightProgress
    }
    
    // ADDED: Dynamic corner radius calculation
    private var dynamicCornerRadius: CGFloat {
        // When expanded (heightProgress = 1.0): radius = 16
        // When collapsed (heightProgress = 0.0): radius = 27
        let expandedRadius: CGFloat = 16
        let collapsedRadius: CGFloat = 27
        return collapsedRadius + (expandedRadius - collapsedRadius) * heightProgress
    }

    
    // Content opacity based on height - ADJUSTED for better visibility
    private var contentOpacity: Double {
        heightProgress > 0.1 ? min(1.0, (heightProgress - 0.1) / 0.2) : 0
    }
    
    // Collapsed content opacity - ADJUSTED for smoother transition
    private var collapsedContentOpacity: Double {
        heightProgress < 0.7 ? max(0, (0.7 - heightProgress) / 0.7) : 0
    }
    
    var canAddTrip: Bool {
        if let lastTrip = searchViewModel.multiCityTrips.last {
            return !lastTrip.toLocation.isEmpty &&
                   !lastTrip.toIataCode.isEmpty &&
                   lastTrip.toLocation != "Destination?"
        }
        return false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Container with dynamic height
            ZStack {
                // Expanded content - LOWERED visibility threshold
                if heightProgress > 0.05 {
                    expandedSearchContent
                        .opacity(contentOpacity)
                        .scaleEffect(max(0.9, 0.9 + (heightProgress * 0.1))) // Adjusted scale for better fit
                }
                
                // Collapsed content - ADJUSTED visibility threshold
                if heightProgress < 0.75 {
                    collapsedSearchContent
                        .opacity(collapsedContentOpacity)
                }
            }
            .frame(height: currentHeight)
            .clipped() // Important: clips content that overflows
        }
        .background(Color.white)
        .cornerRadius(dynamicCornerRadius) // UPDATED: Use dynamic corner radius
        .overlay(
            RoundedRectangle(cornerRadius: dynamicCornerRadius) // UPDATED: Use dynamic corner radius
                .stroke(Color.orange, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .animation(.interpolatingSpring(stiffness: 300, damping: 25), value: heightProgress)
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
    
    // MARK: - Expanded Content - INCREASED padding and spacing for proper visibility
    @ViewBuilder
        private var expandedSearchContent: some View {
            VStack(spacing: 16) {
                // Trip Type Tabs - ALWAYS show at the top
                tripTypeTabs
                
                // Search Interface
                if searchViewModel.selectedTab == 2 {
                    updatedMultiCityInterface
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    regularInterface
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.35), value: searchViewModel.selectedTab)
            .padding(20) // Consistent with original
        }
        
        // MARK: - Collapsed Content
        @ViewBuilder
        private var collapsedSearchContent: some View {
            Button(action: onSearchTap) {
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
                    
                    // Date display
                    Text(formatDatesForCollapsed())
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Spacer()
                    
                    Text("Search")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 105)
                        .frame(height: 44)
                        .background(
                            RoundedCornersss(tl: 8, tr: 26, bl: 8, br: 26)
                                .fill(Color.orange)
                        )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    
    // MARK: - Trip Type Tabs - ENSURE ALWAYS VISIBLE
    private var tripTypeTabs: some View {
        let titles = ["Return", "One way", "Multi city"]
        let totalWidth = UIScreen.main.bounds.width * 0.65
        let tabWidth = totalWidth / 3
        let padding: CGFloat = 6
        
        return ZStack(alignment: .leading) {
            Capsule()
                .fill(Color(UIColor.systemGray6))
                .frame(height: 44)
                
            Capsule()
                .fill(Color.white)
                .frame(width: tabWidth - (padding * 2), height: 34)
                .offset(x: (CGFloat(searchViewModel.selectedTab) * tabWidth) + padding)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: searchViewModel.selectedTab)
            
            HStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    Button(action: {
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
        .frame(width: totalWidth, height: 44) // Increased frame height to match original
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }
    
    // MARK: - Multi-City Interface (Maintained from original)
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

                    // Always show vertical divider and add flight button when under limit
                    if searchViewModel.multiCityTrips.count < 4 {
                        Rectangle()
                            .frame(width: 1)
                            .foregroundColor(Color.gray.opacity(0.3))
                            .frame(maxHeight: .infinity)

                        Spacer()

                        // Always show Add Flight button, but disable when needed
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
    
    // MARK: - Regular Interface
    private var regularInterface: some View {
        VStack(spacing: 5) {
            fromLocationButton
                .offset(y: fromLocationOffset)
                .opacity(fromLocationOpacity)
                .scaleEffect(fromLocationScale)
                .animation(.easeInOut(duration: 0.3), value: fromLocationOffset)
                .animation(.easeInOut(duration: 0.25), value: fromLocationOpacity)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: fromLocationScale)
                
            ZStack {
                Divider()
                    .padding(.leading, 40)
                    .padding(.trailing, -20)
                    .padding(.vertical, 1)
                
                enhancedSwapButton
            }
            
            toLocationButton
                .offset(y: toLocationOffset)
                .opacity(toLocationOpacity)
                .scaleEffect(toLocationScale)
                .animation(.easeInOut(duration: 0.3), value: toLocationOffset)
                .animation(.easeInOut(duration: 0.25), value: toLocationOpacity)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toLocationScale)
                
            Divider()
                .padding(.leading, 40)
                .padding(.trailing, -20)
                .padding(.vertical, 6)
                
            dateButton
                .padding(.vertical, 4)
                
            Divider()
                .padding(.leading, 40)
                .padding(.trailing, -20)
                .padding(.vertical, 6)
                
            passengerButton
                .padding(.bottom, 4)
           
            searchButton
            
            directFlightsToggle
                .padding(.top, 4)
        }
    }
    
    // MARK: - UI Components
    private var fromLocationButton: some View {
        Button(action: { showingFromLocationSheet = true }) {
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
    
    private var enhancedSwapButton: some View {
        HStack {
            Spacer()
            Button(action: animatedSwapLocations) {
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
                        .foregroundColor(Color.blue)
                        .rotationEffect(.degrees(swapRotationDegrees))
                        .scaleEffect(isSwapping ? 1.1 : 1.0)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 15), value: swapRotationDegrees)
                        .animation(.easeInOut(duration: 0.2), value: isSwapping)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isSwapping)
        }
        .padding(.horizontal)
    }

    private var toLocationButton: some View {
        Button(action: { showingToLocationSheet = true }) {
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
        Button(action: { showingCalendar = true }) {
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
        Button(action: { showingPassengersSheet = true }) {
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
    }
    
    private var searchButton: some View {
        VStack(spacing: 4) {
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
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
                Label("Select location to search flight", systemImage: "exclamationmark.triangle")
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
                .labelsHidden()
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
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
    
    // MARK: - Helper Methods and Properties
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
        if searchViewModel.selectedDates.count == 1 {
            return formatDateForDisplay(searchViewModel.selectedDates[0])
        } else if searchViewModel.selectedDates.count >= 2 {
            let sortedDates = searchViewModel.selectedDates.sorted()
            return "\(formatDateForDisplay(sortedDates[0])) - \(formatDateForDisplay(sortedDates[1]))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, d MMM"
            
            if searchViewModel.isRoundTrip {
                let today = Date()
                let calendar = Calendar.current
                let departureDate = calendar.date(byAdding: .day, value: 7, to: today) ?? today
                let returnDate = calendar.date(byAdding: .day, value: 14, to: today) ?? today
                return "\(formatter.string(from: departureDate)) - \(formatter.string(from: returnDate))"
            } else {
                let today = Date()
                let calendar = Calendar.current
                let departureDate = calendar.date(byAdding: .day, value: 7, to: today) ?? today
                return formatter.string(from: departureDate)
            }
        }
    }

    private func getDateTextColor() -> Color {
        return .primary
    }
    
    private var passengerDisplayText: String {
        let totalPassengers = searchViewModel.adultsCount + searchViewModel.childrenCount
        return "\(totalPassengers) Adult\(totalPassengers > 1 ? "s" : "") - \(searchViewModel.selectedCabinClass)"
    }
    
    private func formatDateForDisplay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E,d MMM"
        return formatter.string(from: date)
    }
    
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
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "MMM"
                let month = monthFormatter.string(from: startDate)
                
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "d"
                let startDay = dayFormatter.string(from: startDate)
                let endDay = dayFormatter.string(from: endDate)
                
                return "\(month) \(startDay)-\(endDay)"
            } else {
                let startFormatter = DateFormatter()
                startFormatter.dateFormat = "MMM d"
                let startFormatted = startFormatter.string(from: startDate)
                
                let endFormatter = DateFormatter()
                endFormatter.dateFormat = "MMM d"
                let endFormatted = endFormatter.string(from: endDate)
                
                return "\(startFormatted)-\(endFormatted)"
            }
        } else if searchViewModel.selectedDates.count == 1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: searchViewModel.selectedDates[0])
        } else {
            return "Anytime"
        }
    }
    
    private func performSearch() {
        // Ensure we always have dates by setting defaults if empty
        if searchViewModel.selectedDates.isEmpty {
            let today = Date()
            let calendar = Calendar.current
            
            if searchViewModel.isRoundTrip {
                let departureDate = calendar.date(byAdding: .day, value: 7, to: today) ?? today
                let returnDate = calendar.date(byAdding: .day, value: 14, to: today) ?? today
                searchViewModel.selectedDates = [departureDate, returnDate]
            } else {
                let departureDate = calendar.date(byAdding: .day, value: 7, to: today) ?? today
                searchViewModel.selectedDates = [departureDate]
            }
        }
        
        // Check for "anytime" or "anywhere" conditions
        let isAnywhereSearch = searchViewModel.toLocation == "Anywhere" || searchViewModel.toLocation == "Destination?" || searchViewModel.toIataCode.isEmpty
        
        if isAnywhereSearch {
            SharedSearchDataStore.shared.isInSearchMode = false
            SharedSearchDataStore.shared.shouldNavigateToTab = 2
            SharedSearchDataStore.shared.shouldExecuteSearch = false
            SharedSearchDataStore.shared.shouldNavigateToExplore = false
            return
        }
        
        // Validation for required fields
        let valid: Bool
        if searchViewModel.selectedTab == 2 {
            valid = searchViewModel.multiCityTrips.allSatisfy { trip in
                !trip.fromIataCode.isEmpty && !trip.toIataCode.isEmpty
            }
        } else {
            valid = !searchViewModel.fromIataCode.isEmpty && !searchViewModel.toIataCode.isEmpty
        }

        if valid {
            showErrorMessage = false
            onSearchTap()
        } else {
            withAnimation {
                showErrorMessage = true
            }
        }
    }
    

    @State private var isRotated = false

    private func animatedSwapLocations() {
        guard !isSwapping else { return }
        
        isSwapping = true
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            swapButtonScale = 1.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                fromLocationOffset = 25
                toLocationOffset = -25
                fromLocationOpacity = 0.7
                toLocationOpacity = 0.7
                fromLocationScale = 0.95
                toLocationScale = 0.95
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                // Toggle rotation between 0 and 180 degrees
                isRotated.toggle()
                swapRotationDegrees = isRotated ? 180 : 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            let tempLocation = searchViewModel.fromLocation
            let tempCode = searchViewModel.fromIataCode
            
            searchViewModel.fromLocation = searchViewModel.toLocation
            searchViewModel.fromIataCode = searchViewModel.toIataCode
            
            searchViewModel.toLocation = tempLocation
            searchViewModel.toIataCode = tempCode
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                fromLocationOffset = 0
                toLocationOffset = 0
                fromLocationOpacity = 1.0
                toLocationOpacity = 1.0
                fromLocationScale = 1.02
                toLocationScale = 1.02
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                swapButtonScale = 1.0
                // Remove this line: swapRotationDegrees += 180
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                fromLocationScale = 1.0
                toLocationScale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isSwapping = false
            
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
        }
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
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
            searchViewModel.multiCityTrips.append(newTrip)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            editingTripIndex = searchViewModel.multiCityTrips.count - 1
            editingFromOrTo = .to
            
            withAnimation(.easeInOut(duration: 0.3)) {
                // Highlight animation if needed
            }
        }
    }
    
    private func removeTrip(at index: Int) {
        guard searchViewModel.multiCityTrips.count > 2,
              index < searchViewModel.multiCityTrips.count else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2)) {
            searchViewModel.multiCityTrips.remove(at: index)
        }
    }
}

// MARK: - RoundedCorners Helper (if not already defined)
struct RoundedCornersss: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.size.width
        let h = rect.size.height

        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)

        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()

        return path
    }
}
