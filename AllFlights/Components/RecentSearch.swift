import SwiftUI

// MARK: - Recent Search Data Model
struct RecentSearchItem: Identifiable, Codable {
    let id = UUID()
    let fromLocation: String
    let toLocation: String
    let fromIataCode: String
    let toIataCode: String
    let passengerCount: Int
    let cabinClass: String
    let searchDate: Date
    
    var displayRoute: String {
        return "\(fromIataCode) - \(toIataCode)"
    }
    
    var passengerInfo: String {
        return "\(passengerCount) \(passengerCount == 1 ? "Person" : "People")"
    }
}

// MARK: - Recent Search Manager
class RecentSearchManager: ObservableObject {
    @Published var recentSearches: [RecentSearchItem] = []
    private let maxRecentSearches = 5
    private let userDefaultsKey = "RecentSearches"
    
    // Singleton instance to ensure consistency across the app
    static let shared = RecentSearchManager()
    
    private init() {
        loadRecentSearches()
    }
    
    // Add a new search to recent searches (allows duplicates)
    func addRecentSearch(
        fromLocation: String,
        toLocation: String,
        fromIataCode: String,
        toIataCode: String,
        adultsCount: Int,
        childrenCount: Int,
        cabinClass: String
    ) {
        // Don't add if either location is empty or placeholder
        guard !fromIataCode.isEmpty && !toIataCode.isEmpty &&
              fromLocation != "Departure?" && toLocation != "Destination?" &&
              fromLocation != "Where from?" && toLocation != "Where to?" else {
            return
        }
        
        let totalPassengers = adultsCount + childrenCount
        let newSearch = RecentSearchItem(
            fromLocation: fromLocation,
            toLocation: toLocation,
            fromIataCode: fromIataCode,
            toIataCode: toIataCode,
            passengerCount: totalPassengers,
            cabinClass: cabinClass,
            searchDate: Date()
        )
        
        // Add new search at the beginning (allowing duplicates)
        recentSearches.insert(newSearch, at: 0)
        
        // Keep only the most recent searches
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
        
        saveRecentSearches()
    }
    
    // Clear all recent searches
    func clearAllRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
    
    // UPDATED: Apply a recent search and automatically trigger the search
    func applyRecentSearch(_ search: RecentSearchItem, to viewModel: SharedFlightSearchViewModel) {
        // Apply search parameters
        viewModel.fromLocation = search.fromLocation
        viewModel.toLocation = search.toLocation
        viewModel.fromIataCode = search.fromIataCode
        viewModel.toIataCode = search.toIataCode
        viewModel.selectedCabinClass = search.cabinClass
        
        // Calculate adults and children from total count
        // For simplicity, assume all are adults if total <= 4, otherwise distribute
        if search.passengerCount <= 4 {
            viewModel.adultsCount = search.passengerCount
            viewModel.childrenCount = 0
        } else {
            viewModel.adultsCount = 4
            viewModel.childrenCount = search.passengerCount - 4
        }
        
        viewModel.updateChildrenAgesArray(for: viewModel.childrenCount)
        
        // Set trip type to round trip by default for recent searches
        viewModel.isRoundTrip = true
        viewModel.selectedTab = 0 // Set to "Return" tab
        
        // ADDED: Set default dates for the search
        setDefaultDatesAndExecuteSearch(for: viewModel)
    }
    
    // ADDED: Helper method to set default dates and execute search
    private func setDefaultDatesAndExecuteSearch(for viewModel: SharedFlightSearchViewModel) {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let returnDate = calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date() // 1 week later
        
        // Set dates in the view model (SharedFlightSearchViewModel uses selectedDates array)
        viewModel.selectedDates = [tomorrow, returnDate]
        
        // ADDED: Automatically execute the search
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.executeSearch()
        }
        
        print("✅ Recent search applied and search executed automatically")
        print("🔍 Route: \(viewModel.fromIataCode) → \(viewModel.toIataCode)")
        
        // Format dates for logging
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        print("📅 Dates: \(formatter.string(from: tomorrow)) - \(formatter.string(from: returnDate))")
        print("👥 Passengers: \(viewModel.adultsCount) adults, \(viewModel.childrenCount) children")
    }
    
    // Save to UserDefaults
    private func saveRecentSearches() {
        if let encoded = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    // Load from UserDefaults
    private func loadRecentSearches() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([RecentSearchItem].self, from: data) else {
            return
        }
        recentSearches = decoded
    }
}

// MARK: - Simplified Recent Search View (No Empty State)
struct RecentSearch: View {
    @ObservedObject var searchViewModel: SharedFlightSearchViewModel
    @State private var hasAppeared = false
    
    // Observe the shared recent search manager directly
    @ObservedObject private var recentSearchManager = RecentSearchManager.shared
    
    var body: some View {
        // UPDATED: Simplified - no empty state handling since HomeView handles conditional display
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(recentSearchManager.recentSearches.enumerated()), id: \.element.id) { index, search in
                    GeometryReader { geometry in
                        RecentSearchCard(
                            search: search,
                            onTap: {
                                // UPDATED: This now automatically triggers the search
                                recentSearchManager.applyRecentSearch(search, to: searchViewModel)
                            }
                        )
                        .scaleEffect(scaleValue(geometry))
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1),
                            value: hasAppeared
                        )
                    }
                    .frame(width: 180, height: 100)
                }
            }
            .padding()
            .padding(.vertical, 10)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                hasAppeared = true
            }
        }
    }
    
    // Calculate scale based on position
    private func scaleValue(_ geometry: GeometryProxy) -> CGFloat {
        let midX = geometry.frame(in: .global).midX
        let viewWidth = UIScreen.main.bounds.width
        let distanceFromCenter = abs(midX - viewWidth / 2)
        let screenProportion = distanceFromCenter / (viewWidth / 2)
        
        // Scale between 1 (centered) and 0.9 (edges)
        return 1.0 - (0.1 * min(screenProportion, 1.0))
    }
}

// MARK: - UPDATED Recent Search Card with visual feedback
struct RecentSearchCard: View {
    let search: RecentSearchItem
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Add haptic feedback for better user experience
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Text(search.displayRoute)
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(search.cabinClass)
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(.gray.opacity(0.8))
                    
                    Circle()
                        .frame(width: 6, height: 6)
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text(search.passengerInfo)
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(.gray.opacity(0.8))
                }
                

            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isPressed ? Color.blue : Color.gray.opacity(0.5), lineWidth: 2)
            )
            .cornerRadius(10)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { pressing in
            isPressed = pressing
        } perform: {
            // This will be handled by the main onTap
        }
    }
}
