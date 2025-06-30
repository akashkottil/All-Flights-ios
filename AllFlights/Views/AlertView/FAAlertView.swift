// Views/Flight Alert View/FAAlertView.swift
import SwiftUI

struct FAAlertView: View {
    @State private var showLocationSheet = false
    @State private var showMyAlertsSheet = false
    
    // ADDED: State for managing created alerts
    @State private var createdAlerts: [AlertResponse] = []
    @State private var isLoadingAlerts = false
    @State private var alertError: String?
    
    // ADDED: Animation state for new alerts
    @State private var newAlertAdded = false
    
    var body: some View {
        ZStack {
            GradientColor.BlueWhite
                .ignoresSafeArea()
            
            VStack {
                FAheader()
                
                // ENHANCED: Show alerts or no alerts message
                if createdAlerts.isEmpty {
                    // Show no alerts state
                    noAlertsContent()
                } else {
                    // Show alerts with data
                    alertsContent()
                }
            }
            
            // Fixed bottom button (unchanged design)
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    // Add new alert button
                    Button(action: {
                        showLocationSheet = true
                    }) {
                        HStack {
                            Image("FAPlus")
                            Text("Add new alert")
                        }
                        .padding()
                    }
                    
                    // Vertical divider
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 1, height: 50)
                    
                    // Hamburger button
                    Button(action: {
                        showMyAlertsSheet = true
                    }) {
                        HStack {
                            Image("FAHamburger")
                        }
                        .padding()
                    }
                }
                .foregroundColor(.white)
                .font(.system(size: 18))
                .background(Color("FABlue"))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            }
        }
        .sheet(isPresented: $showLocationSheet) {
            // FIXED: Pass callback to handle alert creation
            FALocationSheet { alertResponse in
                handleAlertCreated(alertResponse)
            }
        }
        .sheet(isPresented: $showMyAlertsSheet) {
            MyAlertsView()
        }
        .onAppear {
            loadSavedAlerts()
        }
    }
    
    // MARK: - No Alerts Content (Original NoAlert component logic)
    
    @ViewBuilder
    private func noAlertsContent() -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 16) {
                // No alerts icon/image
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "bell.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.6))
                }
                
                Text("No Alerts Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Create your first price alert to get notified when flight prices drop")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Quick action button
                Button(action: {
                    showLocationSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Alert")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(25)
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Alerts Content (Shows created alerts)
    
    @ViewBuilder
    private func alertsContent() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header section
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Active Price Alerts")
                            .font(.system(size: 20, weight: .bold))
                        
                        if createdAlerts.count == 1 {
                            Text("1 active alert")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                        } else {
                            Text("\(createdAlerts.count) active alerts")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    
                    // Add another alert button
                    Button(action: {
                        showLocationSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 20)
                
                // ENHANCED: Show actual alert cards with API data
                ForEach(Array(createdAlerts.enumerated()), id: \.element.id) { index, alert in
                    FACard(alertData: alert)
                        .scaleEffect(newAlertAdded && index == 0 ? 1.05 : 1.0)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .top)),
                            removal: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .trailing))
                        ))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: newAlertAdded)
                        .onTapGesture {
                            // Handle alert card tap if needed
                            print("Alert card tapped: \(alert.id)")
                        }
                }
                
                // Loading indicator
                if isLoadingAlerts {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading alerts...")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                // Error message
                if let error = alertError {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("Error: \(error)")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            loadSavedAlerts()
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }
                    .padding()
                }
                
                Color.clear
                    .frame(height: 100) // Extra padding for bottom button
            }
        }
    }
    
    // MARK: - FIXED Alert Management
    
    private func handleAlertCreated(_ alert: AlertResponse) {
        print("🎉 Alert created successfully - adding to view")
        print("   Alert ID: \(alert.id)")
        print("   Route: \(alert.route.origin_name) → \(alert.route.destination_name)")
        if let cheapestFlight = alert.cheapest_flight {
            print("   Price: \(cheapestFlight.price) \(alert.route.currency)")
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            // Add to the beginning of the array (most recent first)
            createdAlerts.insert(alert, at: 0)
            
            // Keep only the last 10 alerts to prevent memory issues
            if createdAlerts.count > 10 {
                createdAlerts = Array(createdAlerts.prefix(10))
            }
            
            // Trigger animation for new alert
            newAlertAdded = true
        }
        
        // Reset animation state after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                newAlertAdded = false
            }
        }
        
        // Save alerts to persistence
        saveAlertsLocally()
        
        // Clear any errors
        alertError = nil
    }
    
    private func saveAlertsLocally() {
        do {
            let data = try JSONEncoder().encode(createdAlerts)
            UserDefaults.standard.set(data, forKey: "SavedFlightAlerts")
            print("💾 Saved \(createdAlerts.count) alerts locally")
        } catch {
            print("❌ Failed to save alerts locally: \(error)")
            alertError = "Failed to save alert locally"
        }
    }
    
    private func loadSavedAlerts() {
        isLoadingAlerts = true
        alertError = nil
        
        // Simulate loading delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let data = UserDefaults.standard.data(forKey: "SavedFlightAlerts") else {
                print("📭 No saved alerts found")
                isLoadingAlerts = false
                return
            }
            
            do {
                let savedAlerts = try JSONDecoder().decode([AlertResponse].self, from: data)
                withAnimation(.easeInOut(duration: 0.4)) {
                    createdAlerts = savedAlerts
                    isLoadingAlerts = false
                }
                print("📬 Loaded \(savedAlerts.count) saved alerts")
            } catch {
                print("❌ Failed to load saved alerts: \(error)")
                // Clear corrupted data
                UserDefaults.standard.removeObject(forKey: "SavedFlightAlerts")
                alertError = "Failed to load saved alerts"
                isLoadingAlerts = false
            }
        }
    }
    
    // Helper method to remove alert (can be called from FACard)
    func removeAlert(withId alertId: String) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            createdAlerts.removeAll { $0.id == alertId }
        }
        saveAlertsLocally()
        print("🗑️ Removed alert: \(alertId)")
    }
    
    // Helper method to clear all alerts (for testing)
    func clearAllAlerts() {
        withAnimation(.easeInOut(duration: 0.4)) {
            createdAlerts.removeAll()
        }
        UserDefaults.standard.removeObject(forKey: "SavedFlightAlerts")
        print("🧹 Cleared all alerts")
    }
}

// MARK: - FAheader Component (keeping original design)
//struct FAheader: View {
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Flight Alerts")
//                    .font(.system(size: 28, weight: .bold))
//                    .foregroundColor(.white)
//                
//                Text("Get notified when prices drop")
//                    .font(.system(size: 16))
//                    .foregroundColor(.white.opacity(0.8))
//            }
//            
//            Spacer()
//            
//            // Profile or settings button
//            Button(action: {
//                print("Profile/Settings tapped")
//            }) {
//                Circle()
//                    .fill(Color.white.opacity(0.2))
//                    .frame(width: 40, height: 40)
//                    .overlay(
//                        Image(systemName: "person.circle")
//                            .font(.system(size: 20))
//                            .foregroundColor(.white)
//                    )
//            }
//        }
//        .padding(.horizontal, 20)
//        .padding(.top, 10)
//    }
//}

// MARK: - MyAlertsView (Enhanced for better UX)
//struct MyAlertsView: View {
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                
//                VStack(spacing: 16) {
//                    Image(systemName: "bell.badge")
//                        .font(.system(size: 50))
//                        .foregroundColor(.blue)
//                    
//                    Text("Manage Your Alerts")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                    
//                    Text("Here you can view, edit, and manage all your flight price alerts")
//                        .font(.body)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//                }
//                
//                VStack(spacing: 12) {
//                    alertFeatureRow("Real-time Price Monitoring", "bell")
//                    alertFeatureRow("Instant Notifications", "bolt.fill")
//                    alertFeatureRow("Multiple Routes Support", "map")
//                    alertFeatureRow("Smart Price Predictions", "chart.line.uptrend.xyaxis")
//                }
//                .padding()
//                
//                Spacer()
//                
//                Button(action: {
//                    dismiss()
//                }) {
//                    Text("Close")
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 32)
//                        .padding(.vertical, 12)
//                        .background(Color.blue)
//                        .cornerRadius(25)
//                }
//            }
//            .padding()
//            .navigationTitle("My Alerts")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") {
//                        dismiss()
//                    }
//                }
//            }
//        }
//    }
//    
//    private func alertFeatureRow(_ title: String, _ iconName: String) -> some View {
//        HStack {
//            Image(systemName: iconName)
//                .font(.system(size: 16))
//                .foregroundColor(.blue)
//                .frame(width: 24)
//            
//            Text(title)
//                .font(.system(size: 16))
//                .foregroundColor(.primary)
//            
//            Spacer()
//            
//            Image(systemName: "checkmark")
//                .font(.system(size: 14))
//                .foregroundColor(.green)
//        }
//        .padding(.vertical, 8)
//    }
//}

// MARK: - Preview
struct FAAlertView_Previews: PreviewProvider {
    static var previews: some View {
        FAAlertView()
    }
}
