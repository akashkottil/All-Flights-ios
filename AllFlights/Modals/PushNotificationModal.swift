import SwiftUI
import UserNotifications

// MARK: - Push Notification Permission Modal (Direct Overlay)
struct PushNotificationModal: View {
    @Binding var isPresented: Bool
    let onAllow: () -> Void
    let onLater: () -> Void
    
    @State private var isRequesting = false
    @State private var showNotificationAnimation = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                Spacer()
                
                // Animated notification images with zoom in/out effect
                ZStack {
                    // First image (notification inside phone) - shown initially and during zoom in
                    Image("pushNotificationModal1")
                        .opacity(showNotificationAnimation ? 0 : 1)
                        .scaleEffect(showNotificationAnimation ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.8), value: showNotificationAnimation)
                    
                    // Second image (notification outside phone) - shown during zoom out
                    Image("pushNotificationModal2")
                        .opacity(showNotificationAnimation ? 1 : 0)
                        .scaleEffect(showNotificationAnimation ? 1.0 : 1.2)
                        .animation(.easeInOut(duration: 0.8).delay(0.4), value: showNotificationAnimation)
                }
                
                VStack(spacing: 16) {
                    Text("Enable\nPush Notification")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        
                    
                    Text("We'll send you alerts when new deals become\navailable so that you can book your flight at the best price.")
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                       
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
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(width:332,height:52)
                      
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("buttonColor"))
                        )
                        
                    }
                    .disabled(isRequesting)
                    
                    // Later button - No background
                    Button(action: {
                        onLater()
                    }) {
                        Text("Later")
                            .foregroundColor(.primary)
                            .fontWeight(.bold)
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
        .onAppear {
            // Start the zoom in/transition/zoom out animation after modal appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showNotificationAnimation = true
            }
        }
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
            
            // Blue overlay layer (appears when modal is shown)
            if showModal {
                Color.blue
                    .opacity(0.4)
                    .ignoresSafeArea()
                    .zIndex(998) // Just below the modal
                    .transition(.opacity)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showModal)
            }
            
            // Push notification modal (top layer)
            if showModal {
                PushNotificationModal(
                    isPresented: $showModal,
                    onAllow: {
                        notificationManager.requestPermission { granted in
                            // Dismiss both modal and blue overlay together
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showModal = false
                            }
                            onAllow()
                        }
                    },
                    onLater: {
                        // Dismiss both modal and blue overlay together
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showModal = false
                        }
                        onLater()
                    }
                )
                .zIndex(999) // Top layer
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
