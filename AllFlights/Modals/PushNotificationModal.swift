import SwiftUI
import UserNotifications

// MARK: - Push Notification Permission Modal (Direct Overlay)
struct PushNotificationModal: View {
    @Binding var isPresented: Bool
    let onAllow: () -> Void
    let onLater: () -> Void
    
    @State private var isRequesting = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                Spacer()
                
                // Notification bell icon - you can replace with your custom image
                Image("pushNotificationModal") // Replace with your actual image name
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(spacing: 16) {
                    Text("Enable\nPush Notification")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .lineLimit(nil)
                    
                    Text("We'll send you alerts when new deals become available so that you can book your flight at the best price.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .lineSpacing(2)
                }
                
                VStack(spacing: 12) {
                    // Allow button - Orange background
                    Button(action: {
                        isRequesting = true
                        onAllow()
                        
                        // Reset requesting state after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isRequesting = false
                        }
                    }) {
                        HStack {
                            if isRequesting {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            }
                            Text(isRequesting ? "Requesting..." : "Allow")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange)
                        )
                        .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isRequesting)
                    
                    // Later button - No background
                    Button(action: {
                        onLater()
                    }) {
                        Text("Later")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .padding(.horizontal, 20)
                
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
                    .clear                     // Transparent at top
                ],
                startPoint: UnitPoint(x: 0.5, y: 0.85),
                endPoint: .top
            )
        )
        .ignoresSafeArea()
    }
}

// MARK: - Push Notification Manager
@MainActor
class PushNotificationManager: ObservableObject {
    static let shared = PushNotificationManager()
    
    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        checkPermissionStatus()
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.checkPermissionStatus()
                completion(granted)
            }
        }
    }
}

// MARK: - Push Notification Modal Modifier
struct PushNotificationModalModifier: ViewModifier {
    @StateObject private var notificationManager = PushNotificationManager.shared
    @State private var showModal = false
    
    let shouldShow: Bool
    let onAllow: () -> Void
    let onLater: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            // Main content
            content
            
            // Overlay modal directly (NO sheet)
            if showModal {
                PushNotificationModal(
                    isPresented: $showModal,
                    onAllow: {
                        notificationManager.requestPermission { granted in
                            showModal = false
                            onAllow()
                        }
                    },
                    onLater: {
                        showModal = false
                        onLater()
                    }
                )
                .zIndex(999)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showModal)
            }
        }
        .onAppear {
            // Show modal if permission is not determined and shouldShow is true
            if shouldShow && notificationManager.permissionStatus == .notDetermined {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showModal = true
                    }
                }
            }
        }
        .onChange(of: shouldShow) { _, newValue in
            if newValue && notificationManager.permissionStatus == .notDetermined {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showModal = true
                }
            }
        }
    }
}

// MARK: - Easy Extension
extension View {
    func pushNotificationModal(
        shouldShow: Bool = true,
        onAllow: @escaping () -> Void = {},
        onLater: @escaping () -> Void = {}
    ) -> some View {
        modifier(PushNotificationModalModifier(
            shouldShow: shouldShow,
            onAllow: onAllow,
            onLater: onLater
        ))
    }
}


