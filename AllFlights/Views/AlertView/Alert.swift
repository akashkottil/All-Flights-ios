// Views/Flight Alert View/Alert.swift
import SwiftUI

struct AlertScreen: View {
    // ADDED: State to track if user has created alerts
    @State private var hasAlerts = false
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                // Show loading state briefly
                loadingView()
            } else if hasAlerts {
                // Show alert management view when user has alerts
                FAAlertView()
            } else {
                // Show create alert view when no alerts exist
                FACreateView()
            }
        }
        .onAppear {
            checkForExistingAlerts()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AlertCreated"))) { _ in
            // When an alert is created, switch to alert view
            withAnimation(.easeInOut(duration: 0.4)) {
                hasAlerts = true
            }
        }
    }
    
    private func loadingView() -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading alerts...")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GradientColor.BlueWhite.ignoresSafeArea())
    }
    
    private func checkForExistingAlerts() {
        // Simulate brief loading delay for smooth UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Check if user has any saved alerts
            if let data = UserDefaults.standard.data(forKey: "SavedFlightAlerts"),
               let savedAlerts = try? JSONDecoder().decode([AlertResponse].self, from: data),
               !savedAlerts.isEmpty {
                
                withAnimation(.easeInOut(duration: 0.4)) {
                    hasAlerts = true
                    isLoading = false
                }
                print("📱 Found \(savedAlerts.count) existing alerts - showing FAAlertView")
            } else {
                withAnimation(.easeInOut(duration: 0.4)) {
                    hasAlerts = false
                    isLoading = false
                }
                print("📱 No existing alerts found - showing FACreateView")
            }
        }
    }
}

// MARK: - Enhanced FACreateView
//struct FACreateView: View {
//    @State private var showLocationSheet = false
//    
//    var body: some View {
//        ZStack {
//            GradientColor.BlueWhite
//                .ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                // Header
//                FAheader()
//                
//                // Main content
//                VStack(spacing: 24) {
//                    Spacer()
//                    
//                    // Illustration/Icon
//                    VStack(spacing: 20) {
//                        ZStack {
//                            Circle()
//                                .fill(Color.white.opacity(0.2))
//                                .frame(width: 120, height: 120)
//                            
//                            Image(systemName: "bell.badge")
//                                .font(.system(size: 50))
//                                .foregroundColor(.white)
//                        }
//                        
//                        VStack(spacing: 12) {
//                            Text("Create Your First Alert")
//                                .font(.system(size: 28, weight: .bold))
//                                .foregroundColor(.white)
//                                .multilineTextAlignment(.center)
//                            
//                            Text("Get notified instantly when flight prices drop for your favorite routes")
//                                .font(.system(size: 16))
//                                .foregroundColor(.white.opacity(0.8))
//                                .multilineTextAlignment(.center)
//                                .padding(.horizontal, 32)
//                        }
//                    }
//                    
//                    // Features list
//                    VStack(spacing: 16) {
//                        featureRow("Real-time price tracking", "chart.line.uptrend.xyaxis")
//                        featureRow("Instant notifications", "bell.fill")
//                        featureRow("Multiple routes support", "map.fill")
//                        featureRow("Best deals discovery", "star.fill")
//                    }
//                    .padding(.horizontal, 24)
//                    
//                    Spacer()
//                    
//                    // Create Alert Button
//                    Button(action: {
//                        showLocationSheet = true
//                    }) {
//                        HStack {
//                            Image(systemName: "plus.circle.fill")
//                                .font(.system(size: 20))
//                            Text("Create Your First Alert")
//                                .font(.system(size: 18, weight: .semibold))
//                        }
//                        .foregroundColor(.blue)
//                        .padding(.horizontal, 32)
//                        .padding(.vertical, 16)
//                        .background(Color.white)
//                        .cornerRadius(28)
//                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
//                    }
//                    .padding(.horizontal, 24)
//                    .padding(.bottom, 32)
//                }
//            }
//        }
//        .sheet(isPresented: $showLocationSheet) {
//            FALocationSheet { alertResponse in
//                // Handle alert creation
//                handleAlertCreated(alertResponse)
//            }
//        }
//    }
//    
//    private func featureRow(_ title: String, _ iconName: String) -> some View {
//        HStack(spacing: 16) {
//            Image(systemName: iconName)
//                .font(.system(size: 18))
//                .foregroundColor(.white)
//                .frame(width: 24)
//            
//            Text(title)
//                .font(.system(size: 16))
//                .foregroundColor(.white)
//            
//            Spacer()
//        }
//        .padding(.horizontal, 8)
//    }
//    
//    private func handleAlertCreated(_ alert: AlertResponse) {
//        print("🎉 First alert created! Switching to alert view...")
//        
//        // Notify the parent AlertScreen that an alert was created
//        NotificationCenter.default.post(
//            name: NSNotification.Name("AlertCreated"),
//            object: alert
//        )
//    }
//}

#Preview {
    AlertScreen()
}
