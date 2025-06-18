import SwiftUI
import Foundation

@MainActor
class OnboardingManager: ObservableObject {
    static let shared = OnboardingManager()
    
    @Published var isFirstLaunch: Bool
    @Published var hasCompletedOnboarding: Bool
    @Published var shouldShowPushNotificationModal: Bool = false
    
    private let firstLaunchKey = "app_first_launch"
    private let onboardingCompletedKey = "onboarding_completed"
    
    private init() {
        // Check if this is the first launch
        self.isFirstLaunch = !UserDefaults.standard.bool(forKey: firstLaunchKey)
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingCompletedKey)
        
        // If it's first launch, mark it as not first launch anymore
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        }
    }
    
    func completeAuthentication() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingCompletedKey)
        // Show push notification modal after authentication
        shouldShowPushNotificationModal = true
    }
    
    func skipAuthentication() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingCompletedKey)
        // Show push notification modal even when skipping authentication
        shouldShowPushNotificationModal = true
    }
    
    func pushNotificationModalDismissed() {
        shouldShowPushNotificationModal = false
    }
}
