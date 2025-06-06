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
                // Header with clear button
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
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                
                // Anywhere option (for destination search)
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
                
                // Recent searches list
                ForEach(recentSearchManager.recentSearches) { recentSearch in
                    RecentLocationSearchRow(
                        recentSearch: recentSearch,
                        onSelected: {
                            // Convert RecentLocationSearch back to AutocompleteResult
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
                            onLocationSelected(autocompleteResult)
                        },
                        onRemove: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                recentSearchManager.removeRecentSearch(recentSearch)
                            }
                        }
                    )
                    
                    if recentSearch.id != recentSearchManager.recentSearches.last?.id {
                        Divider()
                            .padding(.horizontal)
                    }
                }
                
                // Bottom divider
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.top, 8)
            }
        }
    }
}

// MARK: - Recent Location Search Row
struct RecentLocationSearchRow: View {
    let recentSearch: RecentLocationSearch
    let onSelected: () -> Void
    let onRemove: () -> Void
    @State private var showingDeleteButton = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Location icon
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "clock")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            // Location details
            VStack(alignment: .leading, spacing: 4) {
                Text(recentSearch.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                HStack {
                    Text(recentSearch.iataCode)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Text("•")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(recentSearch.displayDescription)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Remove button (show on long press or swipe)
            if showingDeleteButton {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            if showingDeleteButton {
                showingDeleteButton = false
            } else {
                onSelected()
            }
        }
        .onLongPressGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showingDeleteButton.toggle()
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onRemove()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Time ago helper
extension Date {
    func timeAgoString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
