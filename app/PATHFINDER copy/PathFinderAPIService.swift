//
//  PathFinderAPIService.swift
//  PATHFINDER
//
//  Created by Breck Neal on 5/3/26.
//

import Foundation
import CoreLocation

private struct APITrail: Decodable {
    let id: String
    let name: String
    let kind: String
    let latitude: Double
    let longitude: Double
    let distanceMeters: Double?
}

final class PathFinderAPIService {
    private let baseURL = URL(string: "http://100.117.157.38:5000")!

    func fetchTrails(near coordinate: CLLocationCoordinate2D) async throws -> [Trail] {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("/api/trails"),
            resolvingAgainstBaseURL: false
        )!

        components.queryItems = [
            URLQueryItem(name: "lat", value: String(coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(coordinate.longitude))
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode([APITrail].self, from: data)

        return decoded.map { item in
            Trail(
                id: item.id,
                name: item.name,
                kind: item.kind,
                coordinate: CLLocationCoordinate2D(
                    latitude: item.latitude,
                    longitude: item.longitude
                ),
                distanceMeters: item.distanceMeters
            )
        }
    }
}
