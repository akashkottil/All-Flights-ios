import SwiftUI

// MARK: - Simplified No Results Modal (No Buttons - Back Navigation Only)
struct NoResultsModal: View {
    @Binding var isPresented: Bool
    
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
                        
                        Text("Nothing found for your search.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
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
            // Semi-transparent overlay - allows back button to remain visible
            Color.black.opacity(0.3)
        )
        .ignoresSafeArea()
    }
}

// MARK: - Simplified No Results Modal Modifier
struct NoResultsModalModifier: ViewModifier {
    @Binding var showModal: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            // Main content
            content
            
            // Overlay modal directly (NO sheet)
            if showModal {
                NoResultsModal(isPresented: $showModal)
                    .zIndex(999)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showModal)
            }
        }
    }
}

// MARK: - Simplified Extension
extension View {
    func noResultsModal(isPresented: Binding<Bool>) -> some View {
        modifier(NoResultsModalModifier(showModal: isPresented))
    }
}
