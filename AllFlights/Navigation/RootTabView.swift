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

            FlightListView()
                .tabItem {
                    Label("Flights", systemImage: "airplane")
                }

            ExploreScreen()
                .tabItem {
                    Label("Explore", systemImage: "globe")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
