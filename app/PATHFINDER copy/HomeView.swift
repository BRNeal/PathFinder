//
//  HomeView.swift
//  PATHFINDER
//
//  Created by Breck Neal on 3/22/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var auth: AuthViewModel
    let user: PFUser

    var body: some View {
        TabView {
            NavigationStack {
                ExploreView()
            }
            .tabItem { Label("Explore", systemImage: "map") }

            NavigationStack {
                BookmarksView()
            }
            .tabItem { Label("Saved", systemImage: "bookmark.fill") }

            NavigationStack {
                ProfileView(user: user)
            }
            .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthViewModel
    let user: PFUser

    var body: some View {
        List {
            Section("Account") {
                Text("Username: \(user.username)")
                Text("Email: \(user.email)")
            }
            Section {
                Button(role: .destructive) {
                    auth.logout()
                } label: {
                    Text("Log Out")
                }
            }
        }
        .navigationTitle("Profile")
    }
}
