import Foundation
import Combine

// MARK: - Recent Location Search Model
struct RecentLocationSearch: Codable, Identifiable, Equatable {
    let id = UUID()
    let iataCode: String
    let cityName: String
    let countryName: String
    let airportName: String
    let type: String
    let imageUrl: String
    let timestamp: Date
    
    // For displaying in UI
    var displayName: String {
        return "\(cityName), \(countryName)"
    }
    
    var displayDescription: String {
        return type == "airport" ? airportName : "All Airports"
    }
}

// MARK: - Recent Location Search Manager
class RecentLocationSearchManager: ObservableObject {
    static let shared = RecentLocationSearchManager()
    
    @Published var recentSearches: [RecentLocationSearch] = []
    
    private let userDefaults = UserDefaults.standard
    private let recentSearchesKey = "RecentLocationSearches"
    private let maxRecentSearches = 10
    
    private init() {
        loadRecentSearches()
    }
    
    // MARK: - Public Methods
    
    func addRecentSearch(_ result: AutocompleteResult) {
        let newSearch = RecentLocationSearch(
            iataCode: result.iataCode,
            cityName: result.cityName,
            countryName: result.countryName,
            airportName: result.airportName,
            type: result.type,
            imageUrl: result.imageUrl,
            timestamp: Date()
        )
        
        // Remove if already exists (to avoid duplicates and update timestamp)
        recentSearches.removeAll { $0.iataCode == newSearch.iataCode }
        
        // Add to beginning
        recentSearches.insert(newSearch, at: 0)
        
        // Keep only max number of searches
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
        
        saveRecentSearches()
    }
    
    func removeRecentSearch(_ search: RecentLocationSearch) {
        recentSearches.removeAll { $0.id == search.id }
        saveRecentSearches()
    }
    
    func clearAllRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
    
    // MARK: - Private Methods
    
    private func saveRecentSearches() {
        do {
            let data = try JSONEncoder().encode(recentSearches)
            userDefaults.set(data, forKey: recentSearchesKey)
        } catch {
            print("Failed to save recent searches: \(error)")
        }
    }
    
    private func loadRecentSearches() {
        guard let data = userDefaults.data(forKey: recentSearchesKey) else {
            return
        }
        
        do {
            recentSearches = try JSONDecoder().decode([RecentLocationSearch].self, from: data)
            // Sort by timestamp (newest first)
            recentSearches.sort { $0.timestamp > $1.timestamp }
        } catch {
            print("Failed to load recent searches: \(error)")
            recentSearches = []
        }
    }
}
