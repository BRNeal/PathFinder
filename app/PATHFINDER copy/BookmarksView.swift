//
//  BookmarksView.swift
//  PATHFINDER
//
//  Created by Breck Neal on 4/19/26.
//


import SwiftUI
import SwiftData
import MapKit

struct BookmarksView: View {
    @EnvironmentObject private var auth: AuthViewModel

    var ownerEmail: String { auth.currentUser?.email ?? "" }

    @Query private var bookmarks: [SavedTrail]

    init(ownerEmail: String = "") {
        // Filter later in body via dynamic init pattern (SwiftData limitation workaround)
        _bookmarks = Query()
    }

    var body: some View {
        let filtered = bookmarks.filter { $0.ownerEmail == ownerEmail }

        List {
            if filtered.isEmpty {
                Text("No bookmarks yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(filtered) { item in
                    NavigationLink {
                        SavedTrailGuideView(trail: item)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name).font(.headline)
                            Text(item.kind).font(.subheadline).foregroundStyle(.secondary)
                            if !item.userLog.isEmpty {
                                Text(item.userLog)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            if item.tracePointCount > 1 {
                                Text("Offline trace available")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    deleteFiltered(indexSet, filtered: filtered)
                }
            }
        }
        .navigationTitle("Bookmarks")
        .toolbar { EditButton() }
    }

    @Environment(\.modelContext) private var context
    private func deleteFiltered(_ offsets: IndexSet, filtered: [SavedTrail]) {
        for i in offsets {
            context.delete(filtered[i])
        }
        try? context.save()
    }
}
