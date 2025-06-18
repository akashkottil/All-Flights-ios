import SwiftUI

struct ContentView: View {
    @EnvironmentObject var onboardingManager: OnboardingManager
    
    var body: some View {
        ZStack {
            if onboardingManager.isFirstLaunch && !onboardingManager.hasCompletedOnboarding {
                // Show authentication view for first launch
                AuthenticationView()
                    .transition(.opacity)
            } else {
                // Show main app (home screen with tab view)
                RootTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: onboardingManager.hasCompletedOnboarding)
    }
}



