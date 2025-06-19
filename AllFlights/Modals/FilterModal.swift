import SwiftUI

// MARK: - Filter Modal (No Sheet - Direct Overlay)
struct FilterModal: View {
    @Binding var isPresented: Bool
    let onClearFilters: () -> Void
    let onEditFilters: () -> Void
    
    @State private var isClearing = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                Spacer()
                
                // Filter icon
                Image("filterModal")
                    .font(.system(size: 50))

                
                VStack(spacing: 12) {
                    Text("Edit Filters")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    Text("Edit your filters to see more results or clear all filters.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                }
                
                VStack(spacing: 12) {
                    
                    
                    // Clear Filters button - shows loading state when clearing
                    Button(action: {
                        isClearing = true
                        onClearFilters()
                        
                        // Reset clearing state and dismiss modal after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isClearing = false
                            isPresented = false
                        }
                    }) {
                        HStack {
                            if isClearing {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.blue)
                            }
                            Text(isClearing ? "Clearing..." : "Clear filters")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)                    }
                    .disabled(isClearing)
                }
                
                Spacer()
            }
            .padding(30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            // Same gradient pattern as network modal
            LinearGradient(
                colors: [
                    .white,                    // Pure white at bottom
                    .white,                    // Pure white in middle area
                    .white.opacity(0.95),
                    .white.opacity(0.85),
                    .white.opacity(0.7),
                    .white.opacity(0.5),
                    .white.opacity(0.3),
                    .white.opacity(0.1),
                    .clear                     // Transparent at top (logo area)
                ],
                startPoint: UnitPoint(x: 0.5, y: 0.85),
                endPoint: .top
            )
        )
        .ignoresSafeArea()
    }
}

// MARK: - Filter Modal Modifier
struct FilterModalModifier: ViewModifier {
    @StateObject private var sharedSearchData = SharedSearchDataStore.shared // ADD: Access shared data
    @Binding var showModal: Bool
    let onClearFilters: () -> Void
    let onEditFilters: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            // Main content
            content
            
            // Overlay modal directly (NO sheet)
            if showModal {
                FilterModal(
                    isPresented: $showModal,
                    onClearFilters: onClearFilters,
                    onEditFilters: onEditFilters
                )
                .zIndex(999)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showModal)
            }
        }
        .onChange(of: showModal) { _, isVisible in // ADD: Track modal visibility
            if isVisible {
                sharedSearchData.showModal()
            } else {
                sharedSearchData.hideModal()
            }
        }
    }
}

// MARK: - Easy Extension
extension View {
    func filterModal(
        isPresented: Binding<Bool>,
        onClearFilters: @escaping () -> Void,
        onEditFilters: @escaping () -> Void = {}
    ) -> some View {
        modifier(FilterModalModifier(
            showModal: isPresented,
            onClearFilters: onClearFilters,
            onEditFilters: onEditFilters
        ))
    }
}
