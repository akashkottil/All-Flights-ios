import SwiftUI

struct AuthenticationView: View {
    @StateObject private var onboardingManager = OnboardingManager.shared
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("homeGrad"),
                    .white
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        // Progress indicator
                        HStack(spacing: 4) {
                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: 20, height: 3)
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 12, height: 3)
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 12, height: 3)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    
                    Text("Find Hidden\nFlight Deals")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(nil)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                ZStack{
                    Image("Onboarding")
                        .padding(.bottom,60)
                        
                    // Authentication section
                    VStack(spacing: 16) {
                        Spacer()
                        
                        // Google Sign In
                        Button(action: {
                            // Handle Google sign in
                            handleGoogleSignIn()
                        }) {
                            HStack {
                                Image("google")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 20))
                                    .padding(.leading)
                                Spacer()
                                Text("Sign in with Google")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Apple Sign In
                        Button(action: {
                            // Handle Apple sign in
                            handleAppleSignIn()
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 20))
                                    .padding(.leading)
                                Spacer()
                                Text("Sign in with Apple")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Maybe Later
                        Button(action: {
                            // Skip authentication and go to home with push notification modal
                            onboardingManager.skipAuthentication()
                        }) {
                            Text("Maybe Later")
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .padding(.vertical, 16)
                        }
                        
                        // Terms text
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .font(.system(size: 12))
                                .padding(10)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Rectangle())
                                .cornerRadius(4)
                                .frame(width: 22, height: 22)
                            
                            Text("By creating or logging into an account you're agreeing with our terms and conditions and privacy statement")
                                .font(.system(size: 12))
                                .foregroundColor(.primary.opacity(0.7))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    private func handleGoogleSignIn() {
        // Add your Google sign in logic here
        print("Google Sign In tapped")
        // After successful authentication:
        onboardingManager.completeAuthentication()
    }
    
    private func handleAppleSignIn() {
        // Add your Apple sign in logic here
        print("Apple Sign In tapped")
        // After successful authentication:
        onboardingManager.completeAuthentication()
    }
}
