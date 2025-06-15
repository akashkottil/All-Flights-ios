import SwiftUI
import Network

// MARK: - Network Connection Modal (No Sheet - Direct Overlay)
struct NetworkConnectionModal: View {
    @Binding var isPresented: Bool
    let onRetry: () -> Void
    
    @State private var isRetrying = false
    
    var body: some View {
        ZStack {
            // NO background overlay - let the content show through
            // The gradient will handle the background effect
            
            VStack(spacing: 20) {
                Spacer()
                Spacer()
                
                // WiFi slash icon
                Image(systemName: "wifi.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                VStack(spacing: 12) {
                    Text("Are we on airplane mode?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    Text("Looks like the connection took a break. Give your internet a quick check and we'll be right back!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                }
                
                // Try Again button - shows loading state when retrying
                Button(action: {
                    isRetrying = true
                    onRetry()
                    
                    // Reset retry state after a delay (in case connection doesn't come back immediately)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        isRetrying = false
                    }
                }) {
                    HStack {
                        if isRetrying {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        }
                        Text(isRetrying ? "Retrying..." : "Try Again")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange)
                    )
                    .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isRetrying)
                
                Spacer()
            }
            .padding(30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            // Your gradient: pure white at bottom, start fading from logo area
            // This allows the logo and header to show through while covering content below
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
                startPoint: UnitPoint(x: 0.5, y: 0.85), // Start fading from ~85% down (logo area)
                endPoint: .top
            )
        )
        .ignoresSafeArea()
    }
}

// MARK: - Network Monitor
@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    @Published var isConnected = true
    
    private init() {
        monitor.pathUpdateHandler = { path in
            Task { @MainActor in
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}

// MARK: - Network Modal Modifier (FIXED - No Sheet)
struct NetworkModalModifier: ViewModifier {
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var showModal = false
    @State private var wasConnected = true
    
    let onRetry: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            // Main content
            content
            
            // Overlay modal directly (NO sheet)
            if showModal {
                NetworkConnectionModal(isPresented: $showModal, onRetry: onRetry)
                    .zIndex(999)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showModal)
            }
        }
        .onChange(of: networkMonitor.isConnected) { _, isConnected in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                if wasConnected && !isConnected {
                    // Connection lost - show modal
                    showModal = true
                } else if !wasConnected && isConnected {
                    // Connection restored - ONLY NOW dismiss modal
                    showModal = false
                    // Auto refresh happens, but modal stays until connection is actually back
                    onRetry()
                }
                wasConnected = isConnected
            }
        }
    }
}

// MARK: - Easy Extension (Same as before)
extension View {
    func networkModal(onRetry: @escaping () -> Void = {}) -> some View {
        modifier(NetworkModalModifier(onRetry: onRetry))
    }
}
