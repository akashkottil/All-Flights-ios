// Views/Flight Tracker/FlightSearchBottomSheet.swift
import SwiftUI

struct trackLocationSheet: View {
    @Binding var isPresented: Bool
    let source: SheetSource
    let searchType: FlightSearchType?
    let onLocationSelected: (FlightTrackAirport) -> Void
    
    @StateObject private var viewModel = AirportSearchViewModel()
    @State private var selectedAirport: FlightTrackAirport?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Top Bar
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Circle().fill(Color.gray.opacity(0.1)))
                }
                Spacer()
                Text(getSheetTitle())
                    .bold()
                    .font(.title2)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }
            .padding()
            
            // Conditional Search Fields based on source
            VStack(spacing: 16) {
                if shouldShowAirportSearch() {
                    airportSearchField()
                }
                
                if shouldShowFlightNumberField() {
                    flightNumberField()
                }
                
                if shouldShowArrivalAirportField() {
                    arrivalAirportField()
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Airport Search Results
            if !viewModel.airports.isEmpty {
                airportResultsList()
            } else if viewModel.isLoading {
                loadingView()
            } else if source == .trackedTab {
                // Show default content for tracked tab
                defaultContent()
            }
            
            Spacer()
        }
        .background(Color.white)
    }
    
    // MARK: - Helper Methods
    
    private func getSheetTitle() -> String {
        switch source {
        case .trackedTab:
            return "Search Flight"
        case .scheduledDeparture:
            return "Select Departure Airport"
        case .scheduledArrival:
            return "Select Arrival Airport"
        }
    }
    
    private func shouldShowAirportSearch() -> Bool {
        switch source {
        case .trackedTab:
            return true // Always show for tracked tab
        case .scheduledDeparture, .scheduledArrival:
            return true // Show airport search for scheduled tabs
        }
    }
    
    private func shouldShowFlightNumberField() -> Bool {
        return source == .trackedTab
    }
    
    private func shouldShowArrivalAirportField() -> Bool {
        return source == .trackedTab
    }
    
    // MARK: - View Components
    
    private func airportSearchField() -> some View {
        HStack {
            TextField(getAirportSearchPlaceholder(), text: $viewModel.searchText)
                .padding()
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange, lineWidth: 1)
        )
    }
    
    private func getAirportSearchPlaceholder() -> String {
        switch source {
        case .trackedTab:
            return "Search Airports"
        case .scheduledDeparture:
            return "Enter departure airport"
        case .scheduledArrival:
            return "Enter arrival airport"
        }
    }
    
    private func flightNumberField() -> some View {
        HStack {
            TextField("Flight Number", text: .constant(""))
                .padding()
            
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
                .padding(.trailing)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange, lineWidth: 1)
        )
    }
    
    private func arrivalAirportField() -> some View {
        HStack {
            TextField("Arrival Airport", text: .constant(""))
                .padding()
            
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
                .padding(.trailing)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange, lineWidth: 1)
        )
    }
    
    private func airportResultsList() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.airports) { airport in
                    airportRowView(airport)
                        .onTapGesture {
                            selectAirport(airport)
                        }
                    
                    if airport.id != viewModel.airports.last?.id {
                        Divider()
                    }
                }
            }
        }
        .frame(maxHeight: 300)
    }
    
    private func airportRowView(_ airport: FlightTrackAirport) -> some View {
        HStack(spacing: 12) {
            // Airport Code
            Text(airport.iataCode)
                .font(.system(size: 16, weight: .bold))
                .padding(8)
                .frame(width: 50, height: 50)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(airport.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text("\(airport.city), \(airport.country)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    private func loadingView() -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Searching airports...")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .frame(height: 100)
    }
    
    private func defaultContent() -> some View {
        VStack(spacing: 20) {
            // Date section show only when all the inputs are filled for tracked tab
            if source == .trackedTab {
                dateSelectionView()
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    // Airlines list
                    airlinesSection()
                    
                    // Popular airports list
                    popularAirportsSection()
                }
            }
        }
    }
    
    private func dateSelectionView() -> some View {
        VStack(alignment: .center) {
            HStack {
                Text("Select date")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    dateCard("Yesterday", "14 May, Tuesday")
                    dateCard("Today", "15 May, Wednesday")
                }
                
                HStack(spacing: 12) {
                    dateCard("Tomorrow", "16 May, Thursday")
                    dateCard("Day After", "17 May, Friday")
                }
            }
        }
        .padding()
    }
    
    private func dateCard(_ title: String, _ date: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
            Text(date)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
    
    private func airlinesSection() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Airlines")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                Spacer()
            }
            
            HStack {
                Image("AirlineLogo")
                    .frame(width: 50, height: 50)
                Text("Airline Name")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                Spacer()
            }
        }
        .padding()
    }
    
    private func popularAirportsSection() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Popular airports")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                Spacer()
            }
            
            HStack {
                Text("COK")
                    .font(.system(size: 14, weight: .medium))
                    .padding(8)
                    .frame(width: 50, height: 50)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                Text("Kochi International Airport")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                Spacer()
            }
        }
        .padding()
    }
    
    private func selectAirport(_ airport: FlightTrackAirport) {
        selectedAirport = airport
        onLocationSelected(airport)
        isPresented = false
    }
}

// MARK: - Default Initializer for Preview
extension trackLocationSheet {
    init() {
        self._isPresented = .constant(true)
        self.source = .trackedTab
        self.searchType = nil
        self.onLocationSelected = { _ in }
    }
}

#Preview {
    trackLocationSheet()
}
