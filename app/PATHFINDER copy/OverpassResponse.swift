//
//  OverpassResponse.swift
//  PATHFINDER
//
//  Created by Breck Neal on 4/19/26.
//


import Foundation
import CoreLocation

// Overpass JSON shapes
private struct OverpassResponse: Codable {
    let elements: [OverpassElement]
}

private struct OverpassElement: Codable {
    let type: String
    let id: Int
    let tags: [String: String]?
    let center: OverpassCenter?
}

private struct OverpassCenter: Codable {
    let lat: Double
    let lon: Double
}

final class OverpassService {
    // Public Overpass endpoint
    private let endpoint = URL(string: "https://overpass-api.de/api/interpreter")!

    func fetchTrails(near coordinate: CLLocationCoordinate2D, radiusMeters: Int = 5000) async throws -> [Trail] {
        let lat = coordinate.latitude
        let lon = coordinate.longitude

        // Query trails/paths near the user; "out center" gives a coordinate for ways.
        let query = """
        [out:json][timeout:25];
        (
          way["highway"="path"](around:\(radiusMeters),\(lat),\(lon));
          way["highway"="footway"](around:\(radiusMeters),\(lat),\(lon));
          relation["route"="hiking"](around:\(radiusMeters),\(lat),\(lon));
        );
        out tags center 60;
        """

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")

        // Overpass expects form body: data=<query>
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        request.httpBody = "data=\(encoded)".data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(OverpassResponse.self, from: data)

        // Map Overpass elements -> Trails
        var results: [Trail] = []
        results.reserveCapacity(decoded.elements.count)

        for el in decoded.elements {
            guard let c = el.center else { continue }
            let tags = el.tags ?? [:]
            let name = tags["name"] ?? "Unnamed Trail"
            let kind = tags["highway"] ?? tags["route"] ?? el.type
            let id = "\(el.type)/\(el.id)"

            results.append(
                Trail(
                    id: id,
                    name: name,
                    kind: kind,
                    coordinate: CLLocationCoordinate2D(latitude: c.lat, longitude: c.lon),
                    distanceMeters: nil
                )
            )
        }

        // Remove duplicates by id (Overpass can repeat in some queries)
        let unique = Dictionary(grouping: results, by: { $0.id }).compactMap { $0.value.first }
        return unique.sorted { $0.name < $1.name }
    }
}