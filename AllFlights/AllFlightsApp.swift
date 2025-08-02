import SwiftUI

@main
struct FlightDealsApp: App {
    @StateObject private var onboardingManager = OnboardingManager.shared
    @StateObject private var userManager = UserManager.shared
    
    init() {
        // Initialize user tracking on app launch
        setupUserTracking()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(onboardingManager)
                .environmentObject(userManager)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Track app becoming active
                    UserManager.shared.createSession(eventType: .appLaunch, vertical: .flight)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    // Optional: Track app going to background
                    UserManager.shared.createSession(eventType: .appLaunch, vertical: .general, tag: "app_background")
                }
        }
    }
    
    private func setupUserTracking() {
        // Initialize user on app launch
        UserManager.shared.initializeUser()
        
        // Optional: Track app installation/first launch
        if UserManager.shared.installDate == nil {
            UserManager.shared.createSession(eventType: .appLaunch, vertical: .general, tag: "first_install")
        }
    }
}
