import SwiftUI

@main
struct FlightDealsApp: App {
    @StateObject private var onboardingManager = OnboardingManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(onboardingManager)
        }
    }
}
