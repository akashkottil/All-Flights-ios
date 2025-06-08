import Foundation
import Combine

// MARK: - Recent Location Search Model
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
    
    // ADD: Track whether this was used as departure or destination
    let searchType: LocationSearchType
    
    // For displaying in UI
    var displayName: String {
        return "\(cityName), \(countryName)"
    }
    
    var displayDescription: String {
        return type == "airport" ? airportName : "All Airports"
    }
}

// ADD: Enum to track search type
enum LocationSearchType: String, Codable, CaseIterable {
    case departure = "departure"
    case destination = "destination"
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
    
    // UPDATE: Add search type parameter
    func addRecentSearch(_ result: AutocompleteResult, searchType: LocationSearchType) {
        let newSearch = RecentLocationSearch(
            iataCode: result.iataCode,
            cityName: result.cityName,
            countryName: result.countryName,
            airportName: result.airportName,
            type: result.type,
            imageUrl: result.imageUrl,
            timestamp: Date(),
            searchType: searchType
        )
        
        // Remove if already exists (to avoid duplicates and update timestamp)
        recentSearches.removeAll {
            $0.iataCode == newSearch.iataCode && $0.searchType == newSearch.searchType
        }
        
        // Add to beginning
        recentSearches.insert(newSearch, at: 0)
        
        // Keep only max number of searches per type
        let departureSearches = recentSearches.filter { $0.searchType == .departure }
        let destinationSearches = recentSearches.filter { $0.searchType == .destination }
        
        let maxPerType = maxRecentSearches / 2
        let trimmedDeparture = Array(departureSearches.prefix(maxPerType))
        let trimmedDestination = Array(destinationSearches.prefix(maxPerType))
        
        recentSearches = (trimmedDeparture + trimmedDestination).sorted { $0.timestamp > $1.timestamp }
        
        saveRecentSearches()
    }
    
    // ADD: Get filtered recent searches by type
    func getRecentSearches(for searchType: LocationSearchType) -> [RecentLocationSearch] {
        return recentSearches
            .filter { $0.searchType == searchType }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    // Keep the old method for backward compatibility (defaults to destination)
    func addRecentSearch(_ result: AutocompleteResult) {
        addRecentSearch(result, searchType: .destination)
    }
    
    func removeRecentSearch(_ search: RecentLocationSearch) {
        recentSearches.removeAll { $0.id == search.id }
        saveRecentSearches()
    }
    
    func clearAllRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
    
    // ADD: Clear searches for specific type
    func clearRecentSearches(for searchType: LocationSearchType) {
        recentSearches.removeAll { $0.searchType == searchType }
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
            let loadedSearches = try JSONDecoder().decode([RecentLocationSearch].self, from: data)
            // Migrate old data that doesn't have searchType
            recentSearches = loadedSearches.map { search in
                // If the search doesn't have a searchType (old data), default to destination
                return search
            }
            // Sort by timestamp (newest first)
            recentSearches.sort { $0.timestamp > $1.timestamp }
        } catch {
            print("Failed to load recent searches (possibly old format): \(error)")
            // Clear old incompatible data
            userDefaults.removeObject(forKey: recentSearchesKey)
            recentSearches = []
        }
    }
}
