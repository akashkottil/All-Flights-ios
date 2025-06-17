import SwiftUI

struct FlightTrackerScreen: View {
    @State private var selectedTab = 1 // 0 for Tracked, 1 for Scheduled
    @State private var searchText = ""
    @State private var selectedFlightType = 0 // 0 for Departures, 1 for Arrivals
    @State private var showingTrackLocationSheet = false
    @State private var currentSheetSource: SheetSource = .trackedTab
    @State private var currentSearchType: FlightSearchType? = nil
    
    // Selected airport data
    @State private var selectedDepartureAirport: FlightTrackAirport?
    @State private var selectedArrivalAirport: FlightTrackAirport?
    
    let flightData = [
        FlightInfo(flightNumber: "6E 6082", airline: "Indigo", destination: "DEL", destinationName: "Delhi", time: "10:00", scheduledTime: "09:50", status: .expected, delay: "5m Early", airlineColor: .blue),
        FlightInfo(flightNumber: "6E 6082", airline: "Indigo", destination: "DEL", destinationName: "Delhi", time: "10:00", scheduledTime: "09:50", status: .expected, delay: "10m Early", airlineColor: .purple),
        FlightInfo(flightNumber: "6E 6082", airline: "Indigo", destination: "DEL", destinationName: "Delhi", time: "10:00", scheduledTime: "09:50", status: .landed, delay: "5m Early", airlineColor: .red),
        FlightInfo(flightNumber: "6E 6082", airline: "Indigo", destination: "DEL", destinationName: "Delhi", time: "10:00", scheduledTime: "09:50", status: .landed, delay: "10m Early", airlineColor: .blue),
        FlightInfo(flightNumber: "6E 6082", airline: "Indigo", destination: "DEL", destinationName: "Delhi", time: "10:00", scheduledTime: "09:50", status: .cancelled, delay: "", airlineColor: .blue),
        FlightInfo(flightNumber: "6E 6082", airline: "Indigo", destination: "DEL", destinationName: "Delhi", time: "10:00", scheduledTime: "09:50", status: .landed, delay: "", airlineColor: .purple)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                GradientColor.BlueWhite
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Tab Selection
                    tabSelectionView
                    
                    // Content based on selected tab
                    if selectedTab == 0 {
                        trackedTabContent
                    } else {
                        scheduledTabContent
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingTrackLocationSheet) {
                trackLocationSheet(
                    isPresented: $showingTrackLocationSheet,
                    source: currentSheetSource,
                    searchType: currentSearchType,
                    onLocationSelected: handleLocationSelected
                )
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 20) {
            Text("Track Flights")
                .font(.system(size: 24))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 10)
        }
    }
    
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 0) {
                // Tracked Tab
                Button(action: { selectedTab = 0 }) {
                    Text("Tracked")
                        .font(selectedTab == 0 ? Font.system(size: 13, weight: .bold) : Font.system(size: 13, weight: .regular))
                        .foregroundColor(selectedTab == 0 ? Color(hex: "006CE3") : .black)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            selectedTab == 0 ? Color.white : Color.clear
                        )
                        .cornerRadius(20)
                }
                
                // Scheduled Tab
                Button(action: { selectedTab = 1 }) {
                    Text("Scheduled")
                        .font(selectedTab == 1 ? Font.system(size: 13, weight: .bold) : Font.system(size: 13, weight: .regular))
                        .foregroundColor(selectedTab == 1 ? Color(hex: "006CE3") : .black)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            selectedTab == 1 ? Color.white : Color.clear
                        )
                        .cornerRadius(20)
                }
            }
            .padding(4)
            .background(Color(hex: "EFF1F4"))
            .cornerRadius(24)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var trackedTabContent: some View {
        VStack(spacing: 20) {
            // Search Field for Tracked Tab
            trackedSearchFieldView
            
            // Empty State
            Spacer()
            
            VStack(spacing: 16) {
                ZStack {
                    Image("NoFlights")
                        .frame(width: 92, height: 92)
                }
                
                Text("No Tracked Flights")
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Check real-time flight status instantly")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
    
    private var scheduledTabContent: some View {
        VStack(spacing: 0) {
            // Search Field for Scheduled
            scheduledSearchFieldView
            
            // Departures/Arrivals Filter
            departureArrivalFilter
            
            // Flight List Header
            flightListHeader
            
            // Flight List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(flightData.indices, id: \.self) { index in
                        flightRowView(flightData[index])
                        
                        if index < flightData.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var trackedSearchFieldView: some View {
        HStack {
            TextField("Try flight number \"6E 6083\"", text: $searchText)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                )
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .onTapGesture {
                    openTrackLocationSheet(source: .trackedTab)
                }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var scheduledSearchFieldView: some View {
        HStack {
            HStack {
                if selectedFlightType == 0 { // Departures
                    if let selectedAirport = selectedDepartureAirport {
                        Text(selectedAirport.iataCode)
                            .foregroundColor(.black)
                            .font(.system(size: 14, weight: .semibold))
                        Text(selectedAirport.city)
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .regular))
                    } else {
                        Text("Select departure airport")
                            .foregroundColor(.gray)
                            .font(.system(size: 16, weight: .regular))
                    }
                } else { // Arrivals
                    if let selectedAirport = selectedArrivalAirport {
                        Text(selectedAirport.iataCode)
                            .foregroundColor(.black)
                            .font(.system(size: 14, weight: .semibold))
                        Text(selectedAirport.city)
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .regular))
                    } else {
                        Text("Select arrival airport")
                            .foregroundColor(.gray)
                            .font(.system(size: 16, weight: .regular))
                    }
                }
                
                Spacer()
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.3), lineWidth: 1)
            )
            .font(.system(size: 16))
            .onTapGesture {
                if selectedFlightType == 0 {
                    openTrackLocationSheet(source: .scheduledDeparture)
                } else {
                    openTrackLocationSheet(source: .scheduledArrival)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var departureArrivalFilter: some View {
        HStack(spacing: 12) {
            Button(action: {
                selectedFlightType = 0
                // Clear arrival airport when switching to departures
                selectedArrivalAirport = nil
            }) {
                Text("Departures")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(selectedFlightType == 0 ? Color(hex: "006CE3") : .black)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        selectedFlightType == 0 ? Color.white : Color.clear
                    )
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedFlightType == 0 ? Color(hex: "006CE3") : Color.gray, lineWidth: 1)
                    )
            }
            
            Button(action: {
                selectedFlightType = 1
                // Clear departure airport when switching to arrivals
                selectedDepartureAirport = nil
            }) {
                Text("Arrivals")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(selectedFlightType == 1 ? Color(hex: "006CE3") : .black)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        selectedFlightType == 1 ? Color.white : Color.clear
                    )
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedFlightType == 1 ? Color(hex: "006CE3") : Color.gray, lineWidth: 1)
                    )
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var flightListHeader: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    Text("Flights")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)

                    Image("FilterIcon")
                        .resizable()
                        .frame(width: 20, height: 20)
                }

                Spacer()

                Text("To")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)

                Spacer()

                Text("Time")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)

                Spacer()

                Text("Status")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 30)
            .padding(.top, 24)
            .padding(.bottom, 12)

            Divider()
                .background(Color.gray.opacity(0.4))
                .padding(.horizontal, 24)
        }
    }
    
    private func flightRowView(_ flight: FlightInfo) -> some View {
        NavigationLink(destination: FlightDetailScreen()) {
            HStack(alignment: .top, spacing: 12) {
                Image("FlightTrackLogo")
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(flight.flightNumber)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(flight.airline)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 2) {
                    Text(flight.destination)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(flight.destinationName)
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(flight.time)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(flight.scheduledTime)
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(flight.status.displayText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(flight.status == .cancelled ? .white : .rainForest)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(
                            flight.status == .cancelled ? Color.red : Color.clear
                        )
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(flight.status == .cancelled ? Color.red : Color.rainForest, lineWidth: 1)
                        )

                    if !flight.delay.isEmpty {
                        Text(flight.delay)
                            .font(.system(size: 12))
                            .foregroundColor(flight.status.delayColor)
                    }
                }.frame(width: 70, height: 34)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Methods
    
    private func openTrackLocationSheet(source: SheetSource) {
        currentSheetSource = source
        currentSearchType = selectedFlightType == 0 ? .departure : .arrival
        showingTrackLocationSheet = true
    }
    
    private func handleLocationSelected(_ airport: FlightTrackAirport) {
        switch currentSheetSource {
        case .trackedTab:
            // Handle tracked tab selection
            break
        case .scheduledDeparture:
            selectedDepartureAirport = airport
        case .scheduledArrival:
            selectedArrivalAirport = airport
        }
    }
}

// MARK: - Supporting Models and Extensions
struct FlightInfo {
    let flightNumber: String
    let airline: String
    let destination: String
    let destinationName: String
    let time: String
    let scheduledTime: String
    let status: FlightStatus
    let delay: String
    let airlineColor: Color
}

enum FlightStatus {
    case expected
    case landed
    case cancelled
    
    var displayText: String {
        switch self {
        case .expected: return "Expected"
        case .landed: return "Landed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .expected: return .clear
        case .landed: return .clear
        case .cancelled: return .red
        }
    }
    
    var delayColor: Color {
        switch self {
        case .expected: return .rainForest
        case .landed: return .rainForest
        case .cancelled: return .red
        }
    }
}

#Preview {
    FlightTrackerScreen()
}
