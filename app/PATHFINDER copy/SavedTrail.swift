//
//  SavedTrail.swift
//  PATHFINDER
//
//  Created by Breck Neal on 4/19/26.
//


import Foundation
import SwiftData
import CoreLocation

private struct StoredTracePoint: Codable {
    let latitude: Double
    let longitude: Double
}

@Model
final class SavedTrail {
    // Unique per user + trail
    @Attribute(.unique) var bookmarkKey: String

    var ownerEmail: String
    var trailId: String
    var name: String
    var kind: String
    var lat: Double
    var lon: Double
    var traceData: Data?
    var tracePointCount: Int
    var tracedAt: Date?
    var userLog: String
    var createdAt: Date

    init(ownerEmail: String, trailId: String, name: String, kind: String, lat: Double, lon: Double) {
        self.ownerEmail = ownerEmail
        self.trailId = trailId
        self.name = name
        self.kind = kind
        self.lat = lat
        self.lon = lon
        self.traceData = nil
        self.tracePointCount = 0
        self.tracedAt = nil
        self.userLog = ""
        self.createdAt = .now
        self.bookmarkKey = "\(ownerEmail.lowercased()):\(trailId)"
    }

    var traceCoordinates: [CLLocationCoordinate2D] {
        guard
            let traceData,
            let points = try? JSONDecoder().decode([StoredTracePoint].self, from: traceData)
        else {
            return []
        }

        return points.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
    }

    func updateTrace(with coordinates: [CLLocationCoordinate2D]) {
        guard coordinates.count > 1 else { return }

        let points = coordinates.map {
            StoredTracePoint(latitude: $0.latitude, longitude: $0.longitude)
        }

        traceData = try? JSONEncoder().encode(points)
        tracePointCount = points.count
        tracedAt = .now
    }
}
