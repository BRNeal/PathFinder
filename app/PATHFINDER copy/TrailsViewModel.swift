//
//  TrailsViewModel.swift
//  PATHFINDER
//
//  Created by Breck Neal on 4/19/26.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class TrailsViewModel: ObservableObject {
    @Published var trails: [Trail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTrail: Trail?

    private let service = PathFinderAPIService()

    func loadTrails(userLocation: CLLocation) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var fetched = try await service.fetchTrails(near: userLocation.coordinate)

            for i in fetched.indices {
                let t = fetched[i]
                let loc = CLLocation(
                    latitude: t.coordinate.latitude,
                    longitude: t.coordinate.longitude
                )
                fetched[i].distanceMeters = loc.distance(from: userLocation)
            }

            trails = fetched.sorted {
                ($0.distanceMeters ?? .greatestFiniteMagnitude) <
                ($1.distanceMeters ?? .greatestFiniteMagnitude)
            }
        } catch {
            print("Trail API error:", error)
            errorMessage = "Failed to load trails from database."
        }
    }
}
