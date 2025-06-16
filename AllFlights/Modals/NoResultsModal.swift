import SwiftUI

// MARK: - No Results Modal (No Sheet - Direct Overlay)
struct NoResultsModal: View {
    @Binding var isPresented: Bool
    let onTryDifferentSearch: () -> Void
    let onClearFilters: () -> Void
    
    @State private var isSearching = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                
                // Modal content card
                VStack(spacing: 20) {
                    // Lens/Search icon
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)

                    
                    VStack(spacing: 12) {
                        Text("No Results Found")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                        
                        Text("Nothing found for your search. Try adjusting your filters or search criteria.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                    }
                    
                    VStack(spacing: 12) {
                        // Try Different Search button
                        Button(action: {
                            isSearching = true
                            onTryDifferentSearch()
                            
                            // Reset state and dismiss modal after a delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isSearching = false
                                isPresented = false
                            }
                        }) {
                            HStack {
                                if isSearching {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                }
                                Text(isSearching ? "Searching..." : "Try different search")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            )
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isSearching)
                        
                        // Clear Filters button (secondary)
                        Button(action: {
                            onClearFilters()
                            isPresented = false
                        }) {
                            Text("Clear filters")
                                .foregroundColor(.blue)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue, lineWidth: 1)
                                        .fill(Color.clear)
                                )
                        }
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            // Semi-transparent overlay so back button remains accessible
            Color.black.opacity(0.3)
        )
        .ignoresSafeArea()
    }
}

// MARK: - No Results Modal Modifier
struct NoResultsModalModifier: ViewModifier {
    @Binding var showModal: Bool
    let onTryDifferentSearch: () -> Void
    let onClearFilters: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            // Main content
            content
            
            // Overlay modal directly (NO sheet)
            if showModal {
                NoResultsModal(
                    isPresented: $showModal,
                    onTryDifferentSearch: onTryDifferentSearch,
                    onClearFilters: onClearFilters
                )
                .zIndex(999)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showModal)
            }
        }
    }
}

// MARK: - Easy Extension
extension View {
    func noResultsModal(
        isPresented: Binding<Bool>,
        onTryDifferentSearch: @escaping () -> Void,
        onClearFilters: @escaping () -> Void
    ) -> some View {
        modifier(NoResultsModalModifier(
            showModal: isPresented,
            onTryDifferentSearch: onTryDifferentSearch,
            onClearFilters: onClearFilters
        ))
    }
}
