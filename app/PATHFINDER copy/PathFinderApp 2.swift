//
//  PathFinderApp 2.swift
//  PATHFINDER
//
//  Created by Breck Neal on 3/22/26.
//


import SwiftUI
import SwiftData

@main
struct PathFinderApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [PFUser.self , SavedTrail.self])
    }
}
