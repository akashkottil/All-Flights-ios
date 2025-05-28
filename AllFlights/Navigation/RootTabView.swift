//
//  RootTabView.swift
//  AllFlights
//
//  Created by Swalih Zamnoon on 19/05/25.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            AlertsView()
                .tabItem {
                    Label("Alert", systemImage: "bell.badge.fill")
                }
                .tag(1)

            ExploreScreen()
                .tabItem {
                    Label("Explore", systemImage: "globe")
                }
                .tag(2)

            FlightTrackerScreen()
                .tabItem {
                    Label("Track Flight", systemImage: "paperplane.circle.fill")
                }
                .tag(3)
        }
        
    }
}
