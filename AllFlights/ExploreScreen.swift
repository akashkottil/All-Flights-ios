import SwiftUI

struct ExploreScreen: View {
    
    // MARK: - Properties
    @State private var selectedTab = 0
    @State private var selectedFilterTab = 0
    
    let filterOptions = ["Cheapest flights", "Direct Flights", "Suggested for you"]
    
    // Sample destination data
    let destinations = [
        DestinationItem(country: "India", price: "₹110", image: "india"),
        DestinationItem(country: "Japan", price: "₹150", image: "japan"),
        DestinationItem(country: "Germany", price: "₹200", image: "germany"),
        DestinationItem(country: "Brazil", price: "₹180", image: "brazil"),
        DestinationItem(country: "Australia", price: "₹220", image: "australia"),
        DestinationItem(country: "Canada", price: "$170", image: "canada")
    ]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation bar
            VStack(spacing: 0) {
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    // Trip type tabs
                    HStack(spacing: 0) {
                        TabButton(title: "Return", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        TabButton(title: "One way", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        
                        TabButton(title: "Multi city", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                    }
                    .background(Capsule().fill(Color(UIColor.systemGray6)))
                    .padding(.trailing)
                    
                    Spacer()
                    
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Search card
                SearchCard()
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange, lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            )
            .padding()
            
            
            // Main content
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    Text("Explore everywhere")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // Filter tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<filterOptions.count, id: \.self) { index in
                                FilterTabButton(
                                    title: filterOptions[index],
                                    isSelected: selectedFilterTab == index
                                ) {
                                    selectedFilterTab = index
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Destination cards
                    VStack(spacing: 12) {
                        ForEach(destinations) { destination in
                            DestinationCard(item: destination)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
            .background(Color(UIColor.systemGray6))
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Search Card Component
struct SearchCard: View {
    var body: some View {
        VStack(spacing: 5) {
            Divider()
            // From row
            HStack {
                Image(systemName: "airplane.departure")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("From")
                        .font(.system(size: 14, weight: .medium))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        .frame(width: 25, height: 40)
                    Image(systemName: "arrow.left.arrow.right")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .font(.system(size: 10))
                }
                .padding(.leading,30)
                
                Spacer()
                
                Image(systemName: "airplane.arrival")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Anywhere")
                        .font(.system(size: 14, weight: .medium))
                }
            }
            
            
            Divider()
            
            // Date and passengers row
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                
                Text("Sat, 7 Jun -Anytime")
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                Image(systemName: "person")
                    .foregroundColor(.blue)
                
                Text("1, Economy")
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.vertical, 10)
        }
       
       
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
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: isSelected ? 1 : 0)
                )
        }
    }
}

// MARK: - Destination Item Model
struct DestinationItem: Identifiable {
    let id = UUID()
    let country: String
    let price: String
    let image: String
}

// MARK: - Destination Card Component
struct DestinationCard: View {
    let item: DestinationItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Destination image
            Image(item.image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(8)
            
            // Destination information
            VStack(alignment: .leading, spacing: 4) {
                Text("Flights from")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Text(item.country)
                    .font(.system(size: 18, weight: .bold))
                
                Text("Direct")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Price
            Text(item.price)
                .font(.system(size: 20, weight: .bold))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
    }
}

// MARK: - Preview
struct ExploreScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreScreen()
    }
}
