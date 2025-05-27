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
            HomeScreen()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            AlertsView()
                .tabItem {
                    Label("Alert", systemImage: "bell.badge.fill")
                }

            ExploreScreen()
                .tabItem {
                    Label("Explore", systemImage: "globe")
                }

            FlightTrackerScreen()
                .tabItem {
                    Label("Track Flight", systemImage: "paperplane.circle.fill")
                }
        }
    }
}
