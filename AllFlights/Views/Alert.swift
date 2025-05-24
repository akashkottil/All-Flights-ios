import SwiftUI

struct FlightDeal {
    let id = UUID()
    let destination: String
    let country: String
    let departureAirport: String
    let departureCode: String
    let dates: String
    let nights: String
    let originalPrice: Int
    let currentPrice: Int
    let dropAmount: Int
    let imageUrl: String
}

struct AlertsView: View {
    @State private var selectedTab = "All"
    @State private var showAddDeparture = false
    
    // Sample data - you can replace this with your actual data
    @State private var flightDeals: [FlightDeal] = [
        FlightDeal(
            destination: "Agra",
            country: "India",
            departureAirport: "John F. Kennedy International",
            departureCode: "JFK",
            dates: "Fri 13 Jun - Fri 13 Jun",
            nights: "10 Nights",
            originalPrice: 110,
            currentPrice: 55,
            dropAmount: 55,
            imageUrl: "agra_taj_mahal"
        ),
        FlightDeal(
            destination: "Varanasi",
            country: "India",
            departureAirport: "Los Angeles International",
            departureCode: "LAX",
            dates: "Mon 16 Jun - Mon 16 Jun",
            nights: "7 Nights",
            originalPrice: 150,
            currentPrice: 75,
            dropAmount: 75,
            imageUrl: "varanasi_ghats"
        )
    ]
    
    private let tabs = ["All", "JFK - Joh...", "LAX - Lo...", "ORD - O'...", "ATL"]
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with profile icon
                headerView
                
                // Filter tabs
                filterTabsView
                
                // Main content
                if flightDeals.isEmpty {
                    emptyStateView
                } else {
                    dealsListView
                }
                
                Spacer()
            }
            
            // Floating Add Departure button
            VStack {
                Spacer()
                addDepartureButton
                    .padding(.bottom, 100) // Account for tab bar
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Alerts")
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {}) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Text("1")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var filterTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        Text(tab)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedTab == tab ? Color.blue : Color(.systemGray6)
                            )
                            .foregroundColor(selectedTab == tab ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var dealsListView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's price drop alerts")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                Text("Price dropped by at least 30%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .padding(.top)
            
            // Deals
            LazyVStack(spacing: 12) {
                ForEach(flightDeals, id: \.id) { deal in
                    DealCardView(deal: deal)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text("There are no price drop from these location right now")
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Text("Try another departure city")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    private var addDepartureButton: some View {
        Button(action: {
            showAddDeparture = true
        }) {
            HStack {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                Text("Add departure")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal)
    }
}

struct DealCardView: View {
    let deal: FlightDeal
    
    var body: some View {
        HStack(spacing: 12) {
            // Destination image
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.orange]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // You can replace this with actual images
                if deal.destination == "Agra" {
                    Image(systemName: "building.columns")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "sailboat")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                // Drop amount badge
                VStack {
                    HStack {
                        Spacer()
                        Text("$\(deal.dropAmount) drop")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
                .padding(4)
                
                // Departure code
                VStack {
                    Spacer()
                    HStack {
                        Text("From\n\(deal.departureCode) - \(deal.departureAirport.prefix(15))...")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(6)
                    .background(Color.black.opacity(0.5))
                }
            }
            
            // Deal details
            VStack(alignment: .leading, spacing: 4) {
                Text(deal.destination)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(deal.country)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(deal.dates)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(deal.nights)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(alignment: .bottom, spacing: 8) {
                    Text("$\(deal.originalPrice)")
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundColor(.red)
                    
                    Text("$\(deal.currentPrice)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    AlertsView()
}

#Preview("Empty State") {
    AlertsView()
        .onAppear {
            // This will show the empty state
        }
}
