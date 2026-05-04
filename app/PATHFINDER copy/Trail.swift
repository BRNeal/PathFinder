//
//  Trail.swift
//  PATHFINDER
//
//  Created by Breck Neal on 4/19/26.
//


import Foundation
import CoreLocation

struct Trail: Identifiable, Hashable {
    let id: String           // "way/12345"
    let name: String
    let kind: String
    let coordinate: CLLocationCoordinate2D
    var distanceMeters: Double?
}

extension Trail {
    static func == (lhs: Trail, rhs: Trail) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.kind == rhs.kind &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.distanceMeters == rhs.distanceMeters
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(kind)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
        hasher.combine(distanceMeters)
    }
}
