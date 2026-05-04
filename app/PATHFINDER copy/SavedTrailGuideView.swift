//
//  SavedTrailGuideView.swift
//  PATHFINDER
//
//  Created by Codex on 11/10/25.
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData

struct SavedTrailGuideView: View {
    @Environment(\.modelContext) private var context

    let trail: SavedTrail

    @State private var cameraPosition: MapCameraPosition
    @State private var trailLog: String
    @State private var saveMessage: String?

    init(trail: SavedTrail) {
        self.trail = trail

        let center = CLLocationCoordinate2D(latitude: trail.lat, longitude: trail.lon)
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
        _cameraPosition = State(initialValue: .region(region))
        _trailLog = State(initialValue: trail.userLog)
    }

    var body: some View {
        VStack(spacing: 16) {
            Map(position: $cameraPosition) {
                if trail.traceCoordinates.count > 1 {
                    MapPolyline(coordinates: trail.traceCoordinates)
                        .stroke(.blue, lineWidth: 5)
                }

                Marker(trail.name, coordinate: CLLocationCoordinate2D(latitude: trail.lat, longitude: trail.lon))
            }
            .mapControls {
                MapUserLocationButton()
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 8) {
                Text(trail.name)
                    .font(.title3.weight(.semibold))
                Text(trail.kind)
                    .foregroundStyle(.secondary)

                if trail.tracePointCount > 1 {
                    Text("Saved trace points: \(trail.tracePointCount)")
                    Text("This route is stored on device and can be reopened from bookmarks.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No recorded trace saved for this bookmark yet.")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                Text("Trail Log")
                    .font(.headline)

                TextEditor(text: $trailLog)
                    .frame(minHeight: 120)
                    .padding(8)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.quaternary, lineWidth: 1)
                    }

                Button("Save Log") {
                    saveLog()
                }
                .buttonStyle(.borderedProminent)

                if let saveMessage {
                    Text(saveMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
        .navigationTitle("Saved Guide")
    }

    private func saveLog() {
        trail.userLog = trailLog.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            try context.save()
            trailLog = trail.userLog
            saveMessage = "Log saved."
        } catch {
            saveMessage = "Unable to save log."
        }
    }
}
