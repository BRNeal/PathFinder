//
//  TrailDetailView.swift
//  PATHFINDER
//
//  Created by Breck Neal on 4/19/26.
//


import SwiftUI
import SwiftData
import CoreLocation

struct TrailDetailView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    let trail: Trail
    @ObservedObject var locationManager: LocationManager
    @State private var savedMessage: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(trail.name).font(.title2).bold()
                Text("Type: \(trail.kind)").foregroundStyle(.secondary)
                Text("Distance: \(distanceText)").foregroundStyle(.secondary)
                Text(traceStatusText).foregroundStyle(.secondary)

                if let savedMessage {
                    Text(savedMessage).font(.footnote).foregroundStyle(.green)
                }

                if isTracingThisTrail {
                    Button {
                        stopAndSaveTrace()
                    } label: {
                        Text("Stop and Save Trace").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        startTrace()
                    } label: {
                        Text("Start Trace").frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(locationManager.isRecordingTrace)
                    .buttonStyle(.borderedProminent)
                }

                Button {
                    saveBookmark()
                } label: {
                    Text("Save Bookmark").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .padding()
            .navigationTitle("Trail")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var distanceText: String {
        guard let meters = trail.distanceMeters else { return "—" }
        let miles = meters / 1609.344
        return String(format: "%.1f miles", miles)
    }

    private var isTracingThisTrail: Bool {
        locationManager.activeTrailID == trail.id
    }

    private var traceStatusText: String {
        if isTracingThisTrail {
            return "Recording route: \(locationManager.traceCoordinates.count) points captured."
        }

        if locationManager.isRecordingTrace {
            return "Another trail is currently being recorded."
        }

        return "Start a trace to save your walked path for offline guidance."
    }

    private func startTrace() {
        savedMessage = nil
        locationManager.beginTrace(for: trail.id)
    }

    private func stopAndSaveTrace() {
        let coordinates = locationManager.finishTrace()
        saveBookmark(traceCoordinates: coordinates)
    }

    private func saveBookmark() {
        saveBookmark(traceCoordinates: nil)
    }

    private func saveBookmark(traceCoordinates: [CLLocationCoordinate2D]?) {
        guard let user = auth.currentUser else { return }
        let bookmarkKey = "\(user.email.lowercased()):\(trail.id)"

        do {
            let descriptor = FetchDescriptor<SavedTrail>(
                predicate: #Predicate { $0.bookmarkKey == bookmarkKey }
            )

            let saved = try context.fetch(descriptor).first ?? SavedTrail(
                ownerEmail: user.email,
                trailId: trail.id,
                name: trail.name,
                kind: trail.kind,
                lat: trail.coordinate.latitude,
                lon: trail.coordinate.longitude
            )

            saved.name = trail.name
            saved.kind = trail.kind
            saved.lat = trail.coordinate.latitude
            saved.lon = trail.coordinate.longitude

            if let traceCoordinates {
                saved.updateTrace(with: traceCoordinates)
            }

            if saved.modelContext == nil {
                context.insert(saved)
            }

            try context.save()
            if let traceCoordinates, traceCoordinates.count > 1 {
                savedMessage = "Trace saved for offline reuse."
            } else {
                savedMessage = "Saved!"
            }
        } catch {
            savedMessage = "Unable to save right now."
        }
    }
}
