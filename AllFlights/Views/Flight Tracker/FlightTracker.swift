//import SwiftUI
//
//struct FlightTrackerScreen: View {
//    @State private var currentView: ViewState = .empty
//    @State private var activeTab: MainTab = .tracked
//    @State private var scheduledSubTab: ScheduledTab = .departures
//    @State private var searchText: String = ""
//    
//    enum ViewState {
//        case empty, tracked, scheduled, detail
//    }
//    
//    enum MainTab {
//        case tracked, scheduled
//    }
//    
//    enum ScheduledTab {
//        case departures, arrivals
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            if currentView == .detail {
//                flightDetailView
//            } else {
//                mainContentView
//            }
//        }
//        
//    }
//    
//    // MARK: - Main Content
//    var mainContentView: some View {
//        VStack(spacing: 0) {
//            // Header with title and tabs
//            headerSection
//            
//            // Search bar
//            searchSection
//            
//            // Content based on current view
//            contentSection
//                .background(Color(UIColor.systemGray6))
//        }
//        .background(GradientColor.BlueWhite)
//    }
//    
//    var headerSection: some View {
//        VStack(spacing: 25) {
//            Text("Track Flights")
//                .font(.system(size: 28, weight: .bold))
//                .foregroundColor(.white)
//                .padding(.top, 20)
//            
//            // Tab Selector with proper spacing and colors
//            HStack(spacing: 0) {
//                Button(action: {
//                    activeTab = .tracked
//                    currentView = searchText.isEmpty ? .empty : .tracked
//                }) {
//                    Text("Tracked")
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundColor(activeTab == .tracked ? Color(red: 0/255, green: 108/255, blue: 227/255) : .black) // #006CE3 for selected, black for unselected
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 12)
//                        .background(
//                            activeTab == .tracked ? Color.white : Color.clear // #FFFFFF for selected
//                        )
//                        .clipShape(RoundedRectangle(cornerRadius: 32))
//                }
//                
//                Button(action: {
//                    activeTab = .scheduled
//                    currentView = .scheduled
//                }) {
//                    Text("Scheduled")
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundColor(activeTab == .scheduled ? Color(red: 0/255, green: 108/255, blue: 227/255) : .black) // #006CE3 for selected, black for unselected
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 12)
//                        .background(
//                            activeTab == .scheduled ? Color.white : Color.clear // #FFFFFF for selected
//                        )
//                        .clipShape(RoundedRectangle(cornerRadius: 32))
//                }
//            }
//            .padding(.all, 4) // Small padding space between tabs wrapped box and selected tab box
//            .background(Color(red: 239/255, green: 241/255, blue: 244/255)) // #EFF1F4 for tabs wrapped background
//            .clipShape(RoundedRectangle(cornerRadius: 30))
//            .padding(.horizontal, 20)
//            .padding(.bottom, 25)
//            
//        }
//        .padding(.horizontal,50)
//    }
//    
//    var searchSection: some View {
//        VStack {
//            HStack {
//                TextField(activeTab == .tracked ? "Try flight number \"6E 6083\"" : "COK Cochin", text: $searchText)
//                    .textFieldStyle(PlainTextFieldStyle())
//                    .font(.system(size: 16))
//                    .foregroundColor(.black.opacity(1))
//                    .fontWeight(.semibold)
//                    .onChange(of: searchText) { value in
//                        if activeTab == .tracked {
//                            currentView = value.isEmpty ? .empty : .tracked
//                        }
//                    }
//                
//                if !searchText.isEmpty && activeTab == .tracked {
//                    Button(action: {
//                        searchText = ""
//                        currentView = .empty
//                    }) {
//                        Image(systemName: "xmark")
//                            .foregroundColor(.gray)
//                    }
//                } else if activeTab == .scheduled {
//                    Image(systemName: "magnifyingglass")
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding(.horizontal, 15)
//            .padding(.vertical, 12)
//            .background(Color.white)
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .padding(.horizontal, 20)
//            .padding(.bottom, 20)
//        }
//    }
//    
//    var contentSection: some View {
//        VStack(spacing: 0) {
//            if currentView == .scheduled {
//                scheduledFlightsView
//            } else if currentView == .tracked {
//                trackedFlightsView
//            } else {
//                emptyStateView
//            }
//        }
//        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .padding(.horizontal, 0)
//    }
//    
//    // MARK: - Empty State
//    var emptyStateView: some View {
//        VStack(spacing: 20) {
//            Spacer()
//            
//            ZStack {
//                Image("NoFlights")
//                    .font(.system(size: 60))
//                    .foregroundColor(.blue)
////                    .rotationEffect(.degrees(45))
//                
//                VStack {
//                    HStack {
//                        Spacer()
////                        Image(systemName: "xmark")
////                            .font(.system(size: 16, weight: .bold))
////                            .foregroundColor(.white)
////                            .frame(width: 24, height: 24)
////                            .background(Color.red)
////                            .clipShape(Circle())
////                            .offset(x: -10, y: 20)
//                    }
//                    Spacer()
//                }
//                .frame(width: 80, height: 80)
//            }
//            
//            Text("No Tracked Flights")
//                .font(.system(size: 20, weight: .semibold))
//                .foregroundColor(.primary)
//            
//            Text("Check real-time flight status instantly")
//                .font(.system(size: 16))
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//            
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(UIColor.systemGray6))
//    }
//    
//    // MARK: - Tracked Flights
//    var trackedFlightsView: some View {
//        ScrollView {
//            LazyVStack(spacing: 15) {
//                ForEach(sampleTrackedFlights, id: \.id) { flight in
//                    TrackedFlightCard(flight: flight)
//                        .onTapGesture {
//                            currentView = .detail
//                        }
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 20)
//        }
//        .background(Color(UIColor.systemGray6))
//    }
//    
//    // MARK: - Scheduled Flights
//    var scheduledFlightsView: some View {
//        VStack(spacing: 0) {
//            // Sub-tab selector for Departures/Arrivals
//            HStack(spacing: 4) {
//                Button(action: { scheduledSubTab = .departures }) {
//                    Text("Departures")
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundColor(scheduledSubTab == .departures ? .blue : .primary)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 8)
//                        .background(
//                            scheduledSubTab == .departures ? Color.white : Color.clear
//                        )
//                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                }
//                
//                Button(action: { scheduledSubTab = .arrivals }) {
//                    Text("Arrivals")
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundColor(scheduledSubTab == .arrivals ? .blue : .primary)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 8)
//                        .background(
//                            scheduledSubTab == .arrivals ? Color.white : Color.clear
//                        )
//                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                }
//            }
//            .padding(.horizontal, 4)
//            .padding(.vertical, 4)
//            .background(Color(UIColor.systemGray5))
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .padding(.horizontal, 20)
//            .padding(.top, 20)
//            .padding(.bottom, 15)
//            
//            // Table Header
//            HStack {
//                HStack {
//                    Text("Flights")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.secondary)
//                    
//                    VStack(spacing: 2) {
//                        Rectangle()
//                            .frame(width: 12, height: 1)
//                            .foregroundColor(.secondary)
//                        Rectangle()
//                            .frame(width: 12, height: 1)
//                            .foregroundColor(.secondary)
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                
//                Text("To")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.secondary)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                
//                Text("Time")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.secondary)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                
//                Text("Status")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.secondary)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 10)
//            
//            // Flight List
//            ScrollView {
//                LazyVStack(spacing: 0) {
//                    ForEach(Array(sampleScheduledFlights.enumerated()), id: \.element.id) { index, flight in
//                        ScheduledFlightRow(flight: flight, index: index)
//                            .onTapGesture {
//                                currentView = .detail
//                            }
//                        
//                        if index < sampleScheduledFlights.count - 1 {
//                            Divider()
//                                .padding(.horizontal, 20)
//                        }
//                    }
//                }
//            }
//        }
//        .background(Color(UIColor.systemGray6))
//    }
//    
//    // MARK: - Flight Detail View
//    var flightDetailView: some View {
//        VStack(spacing: 0) {
//            // Header
//            HStack {
//                Button(action: {
//                    currentView = .scheduled
//                }) {
//                    Image(systemName: "chevron.left")
//                        .font(.system(size: 18, weight: .medium))
//                        .foregroundColor(.white)
//                }
//                
//                Spacer()
//                
//                VStack(spacing: 2) {
//                    Text("Kochi - Delhi")
//                        .font(.system(size: 17, weight: .semibold))
//                        .foregroundColor(.white)
//                    
//                    Text("28 Jan 2024")
//                        .font(.system(size: 13))
//                        .foregroundColor(.white.opacity(0.8))
//                }
//                
//                Spacer()
//                
//                Button(action: {}) {
//                    Image(systemName: "square.and.arrow.up")
//                        .font(.system(size: 16))
//                        .foregroundColor(.white)
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 15)
//            .background(Color(red: 0.2, green: 0.3, blue: 0.5))
//            
//            // Flight Detail Content
//            flightDetailContent
//        }
//    }
//    
//    var flightDetailContent: some View {
//        ScrollView {
//            VStack(spacing: 15) {
//                // Flight Info Header
//                HStack {
//                    AirlineLogo(code: "6E", color: .blue)
//                    
//                    VStack(alignment: .leading, spacing: 2) {
//                        Text("6E 6082")
//                            .font(.system(size: 16, weight: .semibold))
//                        Text("Indigo")
//                            .font(.system(size: 14))
//                            .foregroundColor(.secondary)
//                    }
//                    
//                    Spacer()
//                    
//                    Text("Scheduled")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.green)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 6)
//                        .background(Color.green.opacity(0.1))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 15)
//                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
//                        )
//                        .clipShape(RoundedRectangle(cornerRadius: 15))
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 20)
//                
//                // Route Information
//                flightRouteInfo
//                
//                // Departure Info
//                departureInfoCard
//                
//                // Arrival Info
//                arrivalInfoCard
//                
//                // Weather Info
//                weatherInfoCard
//                
//                // Actions
//                VStack(spacing: 15) {
//                    HStack {
//                        Text("Notification")
//                            .font(.system(size: 16, weight: .medium))
//                        
//                        Spacer()
//                        
//                        Toggle("", isOn: .constant(false))
//                            .labelsHidden()
//                    }
//                    
//                    Button(action: {}) {
//                        HStack {
//                            Image(systemName: "trash")
//                                .foregroundColor(.red)
//                            Text("Delete")
//                                .foregroundColor(.red)
//                                .font(.system(size: 16, weight: .medium))
//                            Spacer()
//                        }
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.bottom, 30)
//            }
//        }
//        .background(Color(UIColor.systemGray6))
//    }
//    
//    var flightRouteInfo: some View {
//        VStack(spacing: 15) {
//            HStack(alignment: .center) {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("COK")
//                        .font(.system(size: 24, weight: .bold))
//                    Text("Kochi International Airport")
//                        .font(.system(size: 12))
//                        .foregroundColor(.secondary)
//                    HStack(spacing: 8) {
//                        Text("Terminal: T4")
//                            .font(.system(size: 12))
//                            .foregroundColor(.secondary)
//                        Text("Gate: 4A")
//                            .font(.system(size: 12))
//                            .foregroundColor(.secondary)
//                    }
//                }
//                
//                Spacer()
//                
//                VStack(spacing: 8) {
//                    Text("09:32")
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundColor(.green)
//                    Text("Ontime")
//                        .font(.system(size: 12))
//                        .foregroundColor(.green)
//                    Text("15 May, Wed")
//                        .font(.system(size: 12))
//                        .foregroundColor(.secondary)
//                }
//            }
//            
//            HStack {
//                Circle()
//                    .frame(width: 8, height: 8)
//                    .foregroundColor(.gray)
//                
//                Text("2h 10min")
//                    .font(.system(size: 12))
//                    .foregroundColor(.secondary)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(Color.gray.opacity(0.1))
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                
//                Rectangle()
//                    .frame(height: 1)
//                    .foregroundColor(.gray)
//                
//                Circle()
//                    .frame(width: 8, height: 8)
//                    .foregroundColor(.gray)
//            }
//            .padding(.vertical, 8)
//            
//            HStack(alignment: .center) {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("DEL")
//                        .font(.system(size: 24, weight: .bold))
//                    Text("Indira Gandhi Airport")
//                        .font(.system(size: 12))
//                        .foregroundColor(.secondary)
//                    HStack(spacing: 8) {
//                        Text("Terminal: T4")
//                            .font(.system(size: 12))
//                            .foregroundColor(.secondary)
//                        Text("Gate: --")
//                            .font(.system(size: 12))
//                            .foregroundColor(.secondary)
//                    }
//                }
//                
//                Spacer()
//                
//                VStack(spacing: 8) {
//                    Text("12:32")
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundColor(.green)
//                    Text("Ontime")
//                        .font(.system(size: 12))
//                        .foregroundColor(.green)
//                    Text("15 May, Wed")
//                        .font(.system(size: 12))
//                        .foregroundColor(.secondary)
//                }
//            }
//            
//            Text("Updated just Now")
//                .font(.system(size: 13, weight: .medium))
//                .foregroundColor(.green)
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 8)
//                .background(Color.green.opacity(0.1))
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//        }
//        .padding(.horizontal, 20)
//    }
//    
//    var departureInfoCard: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            HStack {
//                Text("COK")
//                    .font(.system(size: 14, weight: .bold))
//                    .foregroundColor(.white)
//                    .frame(width: 32, height: 32)
//                    .background(Color.black)
//                    .clipShape(RoundedRectangle(cornerRadius: 6))
//                
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Kochi, India")
//                        .font(.system(size: 16, weight: .semibold))
//                    Text("Departure")
//                        .font(.system(size: 14))
//                        .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//            }
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Gate Time")
//                    .font(.system(size: 16, weight: .semibold))
//                
//                detailRow(title: "Scheduled", value: "2:00 PM")
//                detailRow(title: "Estimated", value: "2:00 PM")
//                detailRow(title: "Status", value: "On time", valueColor: .green)
//            }
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Runway Time")
//                    .font(.system(size: 16, weight: .semibold))
//                
//                detailRow(title: "Scheduled", value: "2:00 PM")
//                detailRow(title: "Status", value: "1m delayed", valueColor: .red)
//            }
//        }
//        .padding(15)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//        .padding(.horizontal, 20)
//    }
//    
//    var arrivalInfoCard: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            HStack {
//                Text("DEL")
//                    .font(.system(size: 14, weight: .bold))
//                    .foregroundColor(.white)
//                    .frame(width: 32, height: 32)
//                    .background(Color.black)
//                    .clipShape(RoundedRectangle(cornerRadius: 6))
//                
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Delhi, India")
//                        .font(.system(size: 16, weight: .semibold))
//                    Text("Arrival")
//                        .font(.system(size: 14))
//                        .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//            }
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Runway Time")
//                    .font(.system(size: 16, weight: .semibold))
//                
//                detailRow(title: "Scheduled", value: "Unavailable", valueColor: .secondary)
//                detailRow(title: "Status", value: "Unavailable", valueColor: .secondary)
//            }
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Gate Time")
//                    .font(.system(size: 16, weight: .semibold))
//                
//                detailRow(title: "Scheduled", value: "4:50 PM")
//                detailRow(title: "Status", value: "On time", valueColor: .green)
//            }
//        }
//        .padding(15)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//        .padding(.horizontal, 20)
//    }
//    
//    var weatherInfoCard: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Good to Know")
//                .font(.system(size: 16, weight: .semibold))
//            
//            Text("Information about your destination")
//                .font(.system(size: 14))
//                .foregroundColor(.secondary)
//            
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("29°C")
//                        .font(.system(size: 24, weight: .bold))
//                    Text("Might rain in New Delhi")
//                        .font(.system(size: 14))
//                        .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//                
//                HStack {
//                    Image(systemName: "sun.max.fill")
//                        .font(.system(size: 20))
//                        .foregroundColor(.yellow)
//                    
//                    Image(systemName: "cloud.rain.fill")
//                        .font(.system(size: 16))
//                        .foregroundColor(.blue)
//                }
//            }
//        }
//        .padding(15)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//        .padding(.horizontal, 20)
//    }
//    
//    func detailRow(title: String, value: String, valueColor: Color = .primary) -> some View {
//        HStack {
//            Text(title)
//                .font(.system(size: 14))
//                .foregroundColor(.secondary)
//            
//            Spacer()
//            
//            Text(value)
//                .font(.system(size: 14, weight: .medium))
//                .foregroundColor(valueColor)
//        }
//    }
//}
//
//// MARK: - Supporting Views
//
//struct AirlineLogo: View {
//    let code: String
//    let color: Color
//    
//    var body: some View {
//        Text(code)
//            .font(.system(size: 12, weight: .bold))
//            .foregroundColor(.white)
//            .frame(width: 32, height: 32)
//            .background(color)
//            .clipShape(RoundedRectangle(cornerRadius: 6))
//    }
//}
//
//struct TrackedFlightCard: View {
//    let flight: TrackedFlight
//    
//    var body: some View {
//        VStack(spacing: 15) {
//            HStack {
//                AirlineLogo(code: "6E", color: .blue)
//                
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("\(flight.airline) • \(flight.flightNumber)")
//                        .font(.system(size: 16, weight: .semibold))
//                }
//                
//                Spacer()
//                
//                Text("Scheduled")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.green)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 6)
//                    .background(Color.green.opacity(0.1))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 15)
//                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
//                    )
//                    .clipShape(RoundedRectangle(cornerRadius: 15))
//            }
//            
//            HStack(alignment: .center) {
//                VStack {
//                    Text(flight.departureTime)
//                        .font(.system(size: 24, weight: .bold))
//                    Text("\(flight.from) • \(flight.date)")
//                        .font(.system(size: 14))
//                        .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//                
//                VStack(spacing: 8) {
//                    HStack {
//                        Circle()
//                            .frame(width: 8, height: 8)
//                            .foregroundColor(.gray)
//                        
//                        Rectangle()
//                            .frame(height: 1)
//                            .foregroundColor(.gray)
//                        
//                        Circle()
//                            .frame(width: 8, height: 8)
//                            .foregroundColor(.gray)
//                    }
//                    
//                    Text(flight.duration)
//                        .font(.system(size: 12))
//                        .foregroundColor(.secondary)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 4)
//                        .background(Color.gray.opacity(0.1))
//                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                    
//                    Text("Direct")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.green)
//                }
//                
//                Spacer()
//                
//                VStack {
//                    Text(flight.arrivalTime)
//                        .font(.system(size: 24, weight: .bold))
//                    Text("\(flight.to) • \(flight.date)")
//                        .font(.system(size: 14))
//                        .foregroundColor(.secondary)
//                }
//            }
//        }
//        .padding(15)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 15))
//        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
//    }
//}
//
//struct ScheduledFlightRow: View {
//    let flight: ScheduledFlight
//    let index: Int
//    
//    private let airlineColors: [Color] = [.blue, .purple, .red, .blue, .blue, Color(red: 0.4, green: 0.2, blue: 0.6)]
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            HStack(spacing: 10) {
//                AirlineLogo(code: "6E", color: airlineColors[index % airlineColors.count])
//                
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(flight.flightNumber)
//                        .font(.system(size: 14, weight: .semibold))
//                    Text(flight.airline)
//                        .font(.system(size: 12))
//                        .foregroundColor(.secondary)
//                }
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text(flight.destination)
//                    .font(.system(size: 16, weight: .semibold))
//                Text(flight.destinationFull)
//                    .font(.system(size: 14))
//                    .foregroundColor(.secondary)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text(flight.scheduledTime)
//                    .font(.system(size: 16, weight: .semibold))
//                Text(flight.actualTime)
//                    .font(.system(size: 14))
//                    .foregroundColor(.secondary)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(flight.status)
//                    .font(.system(size: 12, weight: .medium))
//                    .foregroundColor(flight.status == "Cancelled" ? .white : .green)
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 4)
//                    .background(
//                        flight.status == "Cancelled" ? Color.red : Color.green.opacity(0.1)
//                    )
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(flight.status == "Cancelled" ? Color.clear : Color.green.opacity(0.3), lineWidth: 1)
//                    )
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                
//                if !flight.statusDetail.isEmpty {
//                    Text(flight.statusDetail)
//                        .font(.system(size: 12))
//                        .foregroundColor(flight.statusDetail.contains("Early") ?
//                                       (flight.statusDetail.contains("10m") ? .red : .green) : .primary)
//                }
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .padding(.horizontal, 20)
//        .padding(.vertical, 15)
//    }
//}
//
//// MARK: - Data Models
//
//struct TrackedFlight {
//    let id = UUID()
//    let airline: String
//    let flightNumber: String
//    let from: String
//    let to: String
//    let departureTime: String
//    let arrivalTime: String
//    let date: String
//    let duration: String
//}
//
//struct ScheduledFlight {
//    let id = UUID()
//    let airline: String
//    let flightNumber: String
//    let destination: String
//    let destinationFull: String
//    let scheduledTime: String
//    let actualTime: String
//    let status: String
//    let statusDetail: String
//}
//
//// MARK: - Sample Data
//
//let sampleTrackedFlights = [
//    TrackedFlight(
//        airline: "Indigo",
//        flightNumber: "6E 6083",
//        from: "COK",
//        to: "CNN",
//        departureTime: "17:10",
//        arrivalTime: "18:30",
//        date: "10 Apr",
//        duration: "12h 10m"
//    )
//]
//
//let sampleScheduledFlights = [
//    ScheduledFlight(airline: "Indigo", flightNumber: "6E 6082", destination: "DEL", destinationFull: "Delhi", scheduledTime: "10:00", actualTime: "09:50", status: "Expected", statusDetail: "5m Early"),
//    ScheduledFlight(airline: "Indigo", flightNumber: "6E 6082", destination: "DEL", destinationFull: "Delhi", scheduledTime: "10:00", actualTime: "09:50", status: "Expected", statusDetail: "10m Early"),
//    ScheduledFlight(airline: "Indigo", flightNumber: "6E 6082", destination: "DEL", destinationFull: "Delhi", scheduledTime: "10:00", actualTime: "09:50", status: "Landed", statusDetail: "5m Early"),
//    ScheduledFlight(airline: "Indigo", flightNumber: "6E 6082", destination: "DEL", destinationFull: "Delhi", scheduledTime: "10:00", actualTime: "09:50", status: "Landed", statusDetail: "10m Early"),
//    ScheduledFlight(airline: "Indigo", flightNumber: "6E 6082", destination: "DEL", destinationFull: "Delhi", scheduledTime: "10:00", actualTime: "09:50", status: "Cancelled", statusDetail: ""),
//    ScheduledFlight(airline: "Indigo", flightNumber: "6E 6082", destination: "DEL", destinationFull: "Delhi", scheduledTime: "10:00", actualTime: "09:50", status: "Landed", statusDetail: "")
//]
//
//struct FlightDetail {
//    let flightNumber: String
//    let airline: String
//    let route: String
//    let date: String
//}
//
//
//#Preview{
//    FlightTrackerScreen()
//}


import SwiftUI

struct FlightTrackerScreen: View {
    @State private var selectedTab = 1 // 0 for Tracked, 1 for Scheduled
    @State private var searchText = ""
    @State private var selectedFlightType = 0 // 0 for Departures, 1 for Arrivals
    
    let flightData = [
        FlightInfo(flightNumber: "6E 6082", airline: "Indigo", destination: "DEL", destinationName: "Delhi", time: "10:00", scheduledTime: "09:50", status: .expected, delay: "5m Early", airlineColor: .blue),
        FlightInfo(flightNumber: "6E 6082", airline: "Indigo", destination: "DEL", destinationName: "Delhi", time: "10:00", scheduledTime: "09:50", status: .expected, delay: "10m Early", airlineColor: .purple),
        FlightInfo(flightNumber: "6E 6082", airline: "Indigo", destination: "DEL", destinationName: "Delhi", time: "10:00", scheduledTime: "09:50", status: .landed, delay: "5m Early", airlineColor: .red),
        FlightInfo(flightNumber: "6E 6082", airline: "Indigo", destination: "DEL", destinationName: "Delhi", time: "10:00", scheduledTime: "09:50", status: .landed, delay: "10m Early", airlineColor: .blue),
        FlightInfo(flightNumber: "6E 6082", airline: "Indigo", destination: "DEL", destinationName: "Delhi", time: "10:00", scheduledTime: "09:50", status: .cancelled, delay: "", airlineColor: .blue),
        FlightInfo(flightNumber: "6E 6082", airline: "Indigo", destination: "DEL", destinationName: "Delhi", time: "10:00", scheduledTime: "09:50", status: .landed, delay: "", airlineColor: .purple)
    ]
    
    var body: some View {
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
            // Search Field
            searchFieldView
            
            // Empty State
            Spacer()
            
            VStack(spacing: 16) {
                // Airplane Icon with X
                ZStack {
                    Image("NoFlights")
                        .frame(width: 92, height: 92)
                        
                    
//                    Image(systemName: "xmark")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(.red)
//                        .offset(x: 20, y: 15)
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
    
    private var searchFieldView: some View {
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
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    
    private var scheduledSearchFieldView: some View {
        HStack {
            HStack {
                Text("COK")
                    .foregroundColor(.black)
                    .font(.system(size: 14, weight: .semibold))
                Text("Cochin")
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .regular))
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
            
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var departureArrivalFilter: some View {
        HStack(spacing: 12) {
            Button(action: { selectedFlightType = 0 }) {
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
            
            Button(action: { selectedFlightType = 1 }) {
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
                .padding(.horizontal, 24) // Match header padding
        }
    }

    
    private func flightRowView(_ flight: FlightInfo) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Airline Logo
//            RoundedRectangle(cornerRadius: 8)
//                .fill(flight.airlineColor)
//                .frame(width: 48, height: 48)
//                .overlay(
//                    Text(flight.airline.prefix(2).uppercased())
//                        .font(.system(size: 12, weight: .bold))
//                        .foregroundColor(.white)
//                )
            Image("FlightTrackLogo")
            
            // Flight Info
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
            
            // Destination
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
            
            // Time
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
            
            // Status
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
