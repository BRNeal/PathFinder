//
//  LocationManager.swift
//  PATHFINDER
//
//  Created by Breck Neal on 4/19/26.
//


import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let minimumRecordedDistance: CLLocationDistance = 10

    @Published var authorization: CLAuthorizationStatus = .notDetermined
    @Published var lastLocation: CLLocation?
    @Published private(set) var traceCoordinates: [CLLocationCoordinate2D] = []
    @Published private(set) var activeTrailID: String?

    var isRecordingTrace: Bool {
        activeTrailID != nil
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestAccess() {
        manager.requestWhenInUseAuthorization()
    }

    func start() {
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
    }

    func beginTrace(for trailID: String) {
        activeTrailID = trailID
        traceCoordinates = []

        if let lastLocation {
            appendTraceCoordinateIfNeeded(lastLocation)
        }
    }

    func finishTrace() -> [CLLocationCoordinate2D] {
        defer {
            activeTrailID = nil
            traceCoordinates = []
        }

        return traceCoordinates
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization = manager.authorizationStatus
        if authorization == .authorizedWhenInUse || authorization == .authorizedAlways {
            start()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location

        if isRecordingTrace {
            appendTraceCoordinateIfNeeded(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Keep simple for now; surface in UI via ViewModel if you want
        print("Location error:", error)
    }

    private func appendTraceCoordinateIfNeeded(_ location: CLLocation) {
        guard location.horizontalAccuracy >= 0 else { return }

        let coordinate = location.coordinate
        guard let lastCoordinate = traceCoordinates.last else {
            traceCoordinates = [coordinate]
            return
        }

        let lastRecorded = CLLocation(latitude: lastCoordinate.latitude, longitude: lastCoordinate.longitude)
        guard location.distance(from: lastRecorded) >= minimumRecordedDistance else { return }

        traceCoordinates.append(coordinate)
    }
}
