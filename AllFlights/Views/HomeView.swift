import SwiftUI

struct HomeScreen: View {
    @State private var isSearchCollapsed = false
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedTab = "Return"
    @State private var directFlightsOnly = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.25, blue: 0.45),
                        Color(red: 0.25, green: 0.35, blue: 0.55)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Top spacing for search card
                        Spacer()
                            .frame(height: isSearchCollapsed ? 80 : 280)
                        
                        // Recent Searches Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Recent Searches")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                                Spacer()
                                Button("Clear All") {
                                    // Clear action
                                }
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    RecentSearchCard(from: "COK", to: "LON", details: "Economy • 3 People")
                                    RecentSearchCard(from: "COK", to: "LON", details: "Economy • 3 People")
                                    RecentSearchCard(from: "COK", to: "LON", details: "Economy • 3 People")
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        
                        // Cheapest Fares Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Cheapest Fares From")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                                Text("Kochi")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 14, weight: .medium))
                                Spacer()
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    DestinationCard(
                                        image: "london",
                                        city: "London",
                                        date: "Sat, 7 Jun",
                                        price: "₹ 2,546",
                                        colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.4)]
                                    )
                                    DestinationCard(
                                        image: "newyork",
                                        city: "New York",
                                        date: "Fri, 10 Jun",
                                        price: "₹ 3,500",
                                        colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.4)]
                                    )
                                    DestinationCard(
                                        image: "tokyo",
                                        city: "Tokyo",
                                        date: "Mon, 12 Jun",
                                        price: "₹ 4,200",
                                        colors: [Color.orange.opacity(0.6), Color.yellow.opacity(0.4)]
                                    )
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        
                        // Action Cards Section
                        HStack(spacing: 16) {
                            ActionCard(
                                icon: "location",
                                title: "Explore",
                                subtitle: "Everywhere",
                                backgroundColor: Color.blue.opacity(0.1),
                                iconColor: .blue
                            )
                            ActionCard(
                                icon: "airplane",
                                title: "Track",
                                subtitle: "your Flights",
                                backgroundColor: Color.purple.opacity(0.1),
                                iconColor: .purple
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        
                        // Notification Card
                        NotificationCard()
                            .padding(.horizontal, 20)
                            .padding(.top, 30)
                        
                        // Rating Card
                        RatingCard()
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        // Bottom spacing
                        Spacer()
                            .frame(height: 120)
                    }
                    .background(
                        GeometryReader { scrollGeo in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKeyy.self,
                                value: scrollGeo.frame(in: .named("scroll")).minY
                            )
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKeyy.self) { value in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if value < -50 && !isSearchCollapsed {
                            isSearchCollapsed = true
                        }
                    }
                }
                
                // Fixed Header
                VStack(spacing: 0) {
                    // Status Bar Area
                    HStack {
                        Text("9:41")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        HStack(spacing: 5) {
                            Image(systemName: "cellularbars")
                            Image(systemName: "wifi")
                            Image(systemName: "battery.100")
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // App Header
                    HStack {
                        Image(systemName: "airplane")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                        Text("All Flights")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                    
                    // Search Card
                    SearchCardd(
                        isCollapsed: isSearchCollapsed,
                        selectedTab: $selectedTab,
                        directFlightsOnly: $directFlightsOnly
                    ) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isSearchCollapsed = false
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.25, blue: 0.45),
                            Color(red: 0.25, green: 0.35, blue: 0.55).opacity(0.9)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
            }
        }
        .ignoresSafeArea()
    }
}

struct SearchCardd: View {
    let isCollapsed: Bool
    @Binding var selectedTab: String
    @Binding var directFlightsOnly: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if isCollapsed {
                // Collapsed State
                HStack {
                    Text("COK - LON  12 Jun")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    Spacer()
                    Button("Search") {
                        // Search action
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.orange)
                    .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(12)
                .onTapGesture {
                    onTap()
                }
            } else {
                // Expanded State
                VStack(spacing: 20) {
                    // Tab Selector
                    HStack(spacing: 0) {
                        ForEach(["Return", "One way", "Multi city"], id: \.self) { tab in
                            Button(action: {
                                selectedTab = tab
                            }) {
                                Text(tab)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(selectedTab == tab ? .blue : .gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                            }
                            if tab != "Multi city" {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Flight Route
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "airplane.departure")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                            Text("COK Cochin")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Image(systemName: "airplane.arrival")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                            Text("DXB Dubai")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                    
                    // Date Selection
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        Text("Sat,7 Jun - Sat,14 Jun")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                    
                    // Passenger Selection
                    HStack {
                        Image(systemName: "person")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        Text("1 Adult - Economy")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Search Button
                    Button(action: {}) {
                        Text("Search Flights")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    // Direct flights toggle
                    HStack {
                        Toggle("Direct flights only", isOn: $directFlightsOnly)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(Color.white)
                .cornerRadius(16)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isCollapsed)
    }
}

struct RecentSearchCard: View {
    let from: String
    let to: String
    let details: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(from) - \(to)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
            Text(details)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DestinationCard: View {
    let image: String
    let city: String
    let date: String
    let price: String
    let colors: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with gradient overlay
            ZStack(alignment: .topLeading) {
                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 140, height: 100)
                    .cornerRadius(12, corners: [.topLeft, .topRight])
                
                // Placeholder for city skyline
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "building.2")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                        Image(systemName: "building")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(city)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Text(date)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text(price)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(12)
        }
        .frame(width: 140)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let backgroundColor: Color
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon == "location" ? "location" : "airplane")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(backgroundColor)
                .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct NotificationCard: View {
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Get notified")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Text("before fares drop")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Text("Lorem ipsum id ut commodo")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Button("Login") {
                    // Login action
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(8)
            }
            
            Spacer()
            
            // Notification bell with animation
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 60, height: 60)
                Image(systemName: "bell.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct RatingCard: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 32))
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("How do you feel?")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Text("Rate us On App store")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button("Rate Us") {
                // Rate action
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(20)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
    }
}



// Helper Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

struct ScrollOffsetPreferenceKeyy: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Preview
struct FlightHomescreenApp_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
