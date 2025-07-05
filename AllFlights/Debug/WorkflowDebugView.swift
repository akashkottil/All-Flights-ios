// Create this as a temporary debug view to test the workflow
// Views/Flight Alert/WorkflowDebugView.swift

import SwiftUI

struct WorkflowDebugView: View {
    @State private var testResult: String = ""
    @State private var isLoading = false
    
    private let alertNetworkManager = AlertNetworkManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Alert Workflow Debug")
                .font(.title)
                .bold()
            
            ScrollView {
                Text(testResult)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 400)
            
            VStack(spacing: 12) {
                Button("Test User Alerts Endpoint") {
                    Task {
                        await testUserAlertsEndpoint()
                    }
                }
                .disabled(isLoading)
                
                Button("Test Workflow Logic") {
                    Task {
                        await testWorkflowLogic()
                    }
                }
                .disabled(isLoading)
                
                Button("Clear Cache") {
                    clearCache()
                }
                .disabled(isLoading)
            }
            .buttonStyle(.borderedProminent)
            
            if isLoading {
                ProgressView("Testing...")
                    .padding()
            }
        }
        .padding()
    }
    
    private func testUserAlertsEndpoint() async {
        isLoading = true
        testResult = "🚀 Testing /api/alerts/user/{user_id}/ endpoint...\n\n"
        
        do {
            let alerts = try await alertNetworkManager.fetchUserAlerts()
            
            testResult += "✅ SUCCESS!\n"
            testResult += "📊 Found \(alerts.count) alerts\n\n"
            
            if alerts.isEmpty {
                testResult += "🏷️  WORKFLOW: Should show FACreateView\n\n"
            } else {
                testResult += "🏷️  WORKFLOW: Should show FAAlertView\n\n"
                
                let alertsWithFlights = alerts.filter { $0.cheapest_flight != nil }
                let alertsWithoutFlights = alerts.filter { $0.cheapest_flight == nil }
                
                testResult += "📋 Alert Analysis:\n"
                testResult += "   • With flights: \(alertsWithFlights.count)\n"
                testResult += "   • Without flights: \(alertsWithoutFlights.count)\n\n"
                
                if alertsWithFlights.isEmpty {
                    testResult += "🏷️  CONTENT: Should show NoAlert component\n\n"
                } else {
                    testResult += "🏷️  CONTENT: Should show FACard components\n\n"
                }
                
                // Show details of each alert
                for (index, alert) in alerts.enumerated() {
                    testResult += "📌 Alert \(index + 1): \(alert.route.origin) → \(alert.route.destination)\n"
                    testResult += "   ID: \(alert.id)\n"
                    testResult += "   Has flight: \(alert.cheapest_flight != nil ? "✅" : "❌")\n"
                    if let flight = alert.cheapest_flight {
                        testResult += "   Price: \(flight.price) \(alert.route.currency)\n"
                        testResult += "   Category: \(flight.price_category)\n"
                    }
                    testResult += "\n"
                }
            }
            
        } catch {
            testResult += "❌ ERROR: \(error.localizedDescription)\n\n"
            testResult += "🏷️  WORKFLOW: Should show FACreateView (fallback)\n\n"
        }
        
        isLoading = false
    }
    
    private func testWorkflowLogic() async {
        isLoading = true
        testResult = "🧪 Testing complete workflow logic...\n\n"
        
        do {
            // Step 1: Test API call
            testResult += "Step 1: Fetching alerts from API...\n"
            let alerts = try await alertNetworkManager.fetchUserAlerts()
            testResult += "✅ API Response: \(alerts.count) alerts\n\n"
            
            // Step 2: Determine which view to show
            testResult += "Step 2: Determining view to show...\n"
            if alerts.isEmpty {
                testResult += "🎯 RESULT: Show FACreateView\n"
                testResult += "   Reason: No alerts found for user\n\n"
            } else {
                testResult += "🎯 RESULT: Show FAAlertView\n"
                testResult += "   Reason: User has \(alerts.count) alerts\n\n"
                
                // Step 3: Determine content within alert view
                testResult += "Step 3: Determining alert view content...\n"
                let alertsWithFlights = alerts.filter { $0.cheapest_flight != nil }
                let alertsWithoutFlights = alerts.filter { $0.cheapest_flight == nil }
                
                testResult += "   Alerts with flights: \(alertsWithFlights.count)\n"
                testResult += "   Alerts without flights: \(alertsWithoutFlights.count)\n\n"
                
                if alertsWithFlights.isEmpty {
                    testResult += "🎯 CONTENT: Show NoAlert component\n"
                    testResult += "   Reason: All alerts have null cheapest_flight\n\n"
                } else {
                    testResult += "🎯 CONTENT: Show FACard components\n"
                    testResult += "   Reason: \(alertsWithFlights.count) alerts have flight data\n\n"
                    
                    // Show which alerts will be displayed
                    testResult += "Cards to display:\n"
                    for alert in alertsWithFlights {
                        let price = alert.cheapest_flight?.price ?? 0
                        let currency = alert.route.currency
                        testResult += "   • \(alert.route.origin) → \(alert.route.destination) (\(price) \(currency))\n"
                    }
                    testResult += "\n"
                }
                
                // Show which alerts won't be displayed
                if !alertsWithoutFlights.isEmpty {
                    testResult += "Alerts not displayed (no flight data):\n"
                    for alert in alertsWithoutFlights {
                        testResult += "   • \(alert.route.origin) → \(alert.route.destination)\n"
                    }
                    testResult += "\n"
                }
            }
            
            testResult += "✅ Workflow logic test complete!\n"
            
        } catch {
            testResult += "❌ Workflow test failed: \(error.localizedDescription)\n"
        }
        
        isLoading = false
    }
    
    private func clearCache() {
        UserDefaults.standard.removeObject(forKey: "CachedAlerts")
        UserDefaults.standard.removeObject(forKey: "AlertsCacheTimestamp")
        testResult = "🗑️ Cache cleared successfully!\n\nNext app launch will fetch fresh data from API.\n"
    }
}

// MARK: - Preview
#Preview {
    WorkflowDebugView()
}
