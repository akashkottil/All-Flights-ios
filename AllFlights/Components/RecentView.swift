import SwiftUI

// MARK: - Recent Location Search View
struct RecentLocationSearchView: View {
    @ObservedObject private var recentSearchManager = RecentLocationSearchManager.shared
    let onLocationSelected: (AutocompleteResult) -> Void
    let showAnywhereOption: Bool
    let onAnywhereSelected: (() -> Void)?
    
    init(onLocationSelected: @escaping (AutocompleteResult) -> Void,
         showAnywhereOption: Bool = false,
         onAnywhereSelected: (() -> Void)? = nil) {
        self.onLocationSelected = onLocationSelected
        self.showAnywhereOption = showAnywhereOption
        self.onAnywhereSelected = onAnywhereSelected
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !recentSearchManager.recentSearches.isEmpty || showAnywhereOption {
                // Header with title and clear button
                HStack {
                    Text("Recent Searches")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if !recentSearchManager.recentSearches.isEmpty {
                        Button("Clear") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                recentSearchManager.clearAllRecentSearches()
                            }
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
               
                
                // Content in ScrollView
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Anywhere option (for destination search) - same style as search results
                        if showAnywhereOption {
                            AnywhereOptionRow()
                                .onTapGesture {
                                    onAnywhereSelected?()
                                }
                            
                            if !recentSearchManager.recentSearches.isEmpty {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Recent searches list using the same LocationResultRow as search results
                        ForEach(recentSearchManager.recentSearches) { recentSearch in
                            // Convert RecentLocationSearch to AutocompleteResult to use same component
                            let autocompleteResult = AutocompleteResult(
                                iataCode: recentSearch.iataCode,
                                airportName: recentSearch.airportName,
                                type: recentSearch.type,
                                displayName: recentSearch.displayName,
                                cityName: recentSearch.cityName,
                                countryName: recentSearch.countryName,
                                countryCode: "", // Not needed for recent searches
                                imageUrl: recentSearch.imageUrl,
                                coordinates: AutocompleteCoordinates(latitude: "0", longitude: "0") // Not needed
                            )
                            
                            // Use the exact same LocationResultRow component as search results
                            LocationResultRow(result: autocompleteResult)
                                .onTapGesture {
                                    onLocationSelected(autocompleteResult)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            recentSearchManager.removeRecentSearch(recentSearch)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}
