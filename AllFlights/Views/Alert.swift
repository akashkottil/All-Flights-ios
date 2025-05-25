import SwiftUI

struct AlertsView: View {
    @State private var showingPriceDrops = false
    @State private var showingLocationSheet = false
    @State private var selectedAirports: [String] = []
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if !showingPriceDrops {
                // Initial screen - Pick departure city
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        // Airplane icon and title
                        VStack(spacing: 8) {
                            Image(systemName: "airplane")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.blue)
                            
                            Text("Alerts")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        
                        // Subtitle
                        VStack(spacing: 4) {
                            Text("Let us know your departure airports,")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                            Text("we'll customize the best flight deals for you!")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    // Pick departure city button
                    Button(action: {
                        showingPriceDrops = true
                        selectedAirports = ["JFK", "LAX", "ORD"]
                    }) {
                        Text("Pick departure city")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            } else {
                // Price drops screen
                VStack(spacing: 0) {
                    // Header with filter
                    HStack {
                        Text("Alerts")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                
                                VStack(spacing: -2) {
                                    Image(systemName: "line.3.horizontal.decrease")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                    Text("1")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Airport filter chips
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    FilterChip(title: "All", isSelected: true)
                                    FilterChip(title: "JFK - John...", isSelected: false)
                                    FilterChip(title: "LAX - Lo...", isSelected: false)
                                    FilterChip(title: "ORD - O...", isSelected: false)
                                    FilterChip(title: "ATL", isSelected: false)
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.top, 20)
                            
                            // Today's price drop section
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Today's price drop alerts")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text("Price dropped by at least 30%")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                
                                // Flight cards
                                VStack(spacing: 12) {
                                    FlightCard(
                                        destination: "Agra",
                                        country: "India",
                                        dates: "Fri 13 Jun - Fri 13 Jun",
                                        nights: "10 Nights",
                                        departure: "JFK - John F. Kenne...",
                                        originalPrice: "$110",
                                        newPrice: "$55",
                                        dropAmount: "$55 drop",
                                        imageName: "taj_mahal"
                                    )
                                    
                                    FlightCard(
                                        destination: "Varanasi",
                                        country: "India",
                                        dates: "Mon 16 Jun - Mon 16 Jun",
                                        nights: "7 Nights",
                                        departure: "LAX - Los Angeles I...",
                                        originalPrice: "$150",
                                        newPrice: "$75",
                                        dropAmount: "$75 drop",
                                        imageName: "varanasi"
                                    )
                                    
                                    FlightCard(
                                        destination: "Jaipur",
                                        country: "India",
                                        dates: "Wed 18 Jun - Wed 18 Jun",
                                        nights: "5 Nights",
                                        departure: "ORD - Chicago O'Hare",
                                        originalPrice: "$130",
                                        newPrice: "$65",
                                        dropAmount: "$65 drop",
                                        imageName: "jaipur"
                                    )
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            Spacer(minLength: 100)
                        }
                    }
                    
                    // Add departure button
                    VStack {
                        Button(action: {
                            showingLocationSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Add departure")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
        }
        .sheet(isPresented: $showingLocationSheet) {
            DepartureLocationSheet()
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .white : .blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(20)
    }
}

struct FlightCard: View {
    let destination: String
    let country: String
    let dates: String
    let nights: String
    let departure: String
    let originalPrice: String
    let newPrice: String
    let dropAmount: String
    let imageName: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Image
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "building.columns")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            .overlay(
                VStack {
                    HStack {
                        Text(dropAmount.replacingOccurrences(of: " drop", with: ""))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .cornerRadius(4)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text("From")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text(departure.prefix(3))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .padding(6),
                alignment: .topLeading
            )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(destination)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(country)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(dates)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text(nights)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text(originalPrice)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .strikethrough()
                    
                    Text(newPrice)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct DepartureLocationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = "Lon"
    
    let airports = [
        Airport(code: "LON", name: "London, United Kingdom", subtitle: "All Airports"),
        Airport(code: "LAX", name: "California, United States", subtitle: "Los Angeles, United States"),
        Airport(code: "NRT", name: "Tokyo, Japan", subtitle: "Tokyo, Japan"),
        Airport(code: "CDG", name: "Île-de-France, France", subtitle: "Paris, France"),
        Airport(code: "HKG", name: "Hong Kong", subtitle: "Hong Kong"),
        Airport(code: "SYD", name: "New South Wales, Australia", subtitle: "Sydney, Australia"),
        Airport(code: "YYZ", name: "Ontario, Canada", subtitle: "Toronto, Canada")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Departure")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Button(action: {}) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.clear)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Search field
                HStack {
                    TextField("Search airports", text: $searchText)
                        .font(.system(size: 16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            HStack {
                                Spacer()
                                if !searchText.isEmpty {
                                    Button(action: { searchText = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.trailing, 12)
                                }
                            }
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // Use current location
                Button(action: {}) {
                    HStack(spacing: 12) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                        
                        Text("Use Current Location")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                
                // Airport list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(airports.filter { airport in
                            searchText.isEmpty || airport.name.localizedCaseInsensitiveContains(searchText) || airport.code.localizedCaseInsensitiveContains(searchText)
                        }) { airport in
                            AirportRow(airport: airport)
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct AirportRow: View {
    let airport: Airport
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                // Airport code
                Text(airport.code)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 40, alignment: .leading)
                
                // Airport details
                VStack(alignment: .leading, spacing: 2) {
                    Text(airport.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(airport.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Airport: Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let subtitle: String
}

#Preview {
    AlertsView()
}
