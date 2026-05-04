//
//  ExploreView.swift
//  PATHFINDER
//
//  Created by Breck Neal on 4/19/26.
//


import SwiftUI
import MapKit
import SwiftData
import CoreLocation

struct ExploreView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var auth: AuthViewModel

    @StateObject private var locationManager = LocationManager()
    @StateObject private var vm = TrailsViewModel()

    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        VStack(spacing: 0) {
            // Map
            Map(position: $cameraPosition) {
                if locationManager.traceCoordinates.count > 1 {
                    MapPolyline(coordinates: locationManager.traceCoordinates)
                        .stroke(.blue, lineWidth: 5)
                }

                ForEach(vm.trails) { trail in
                    Annotation(trail.name, coordinate: trail.coordinate) {
                        Button {
                            vm.selectedTrail = trail
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                        }
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
            }
            .frame(height: 320)

            // Status / errors
            if vm.isLoading {
                ProgressView("Loading trails…").padding(.vertical, 8)
            } else if let msg = vm.errorMessage {
                Text(msg).foregroundStyle(.red).padding(.vertical, 8)
            } else if locationManager.authorization == .denied || locationManager.authorization == .restricted {
                Text("Location permission is required to find nearby trails.")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            }

            // TableView/List
            List(vm.trails) { trail in
                Button {
                    vm.selectedTrail = trail
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trail.name).font(.headline)
                        Text("\(trail.kind) • \(formatDistance(trail.distanceMeters))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Explore")
        .toolbar {
            if locationManager.isRecordingTrace {
                Text("Tracing")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.blue)
            }

            Button("Refresh") {
                Task { await refreshIfPossible() }
            }
        }
        .onAppear {
            locationManager.requestAccess()
        }
        .onChange(of: locationManager.lastLocation) { _, newLoc in
            guard let loc = newLoc else { return }
            cameraPosition = .region(MKCoordinateRegion(center: loc.coordinate,
                                                      span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)))
            Task { await vm.loadTrails(userLocation: loc) }
        }
        .sheet(item: $vm.selectedTrail) { trail in
            TrailDetailView(trail: trail, locationManager: locationManager)
        }
    }

    private func refreshIfPossible() async {
        guard let loc = locationManager.lastLocation else { return }
        await vm.loadTrails(userLocation: loc)
    }

    private func formatDistance(_ meters: Double?) -> String {
        guard let meters else { return "—" }
        let miles = meters / 1609.344
        return String(format: "%.1f mi", miles)
    }
}
