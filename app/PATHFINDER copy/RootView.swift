//
//  RootView.swift
//  PATHFINDER
//
//  Created by Breck Neal on 3/22/26.
//


import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var auth = AuthViewModel()

    var body: some View {
        Group {
            if let user = auth.currentUser {
                HomeView(user: user)
                    .environmentObject(auth)
            } else {
                LoginView()
                    .environmentObject(auth)
            }
        }
        .onAppear {
            auth.bootstrap(context: context)
        }
    }
}