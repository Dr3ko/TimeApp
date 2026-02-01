//
//  TimeAppApp.swift
//  TimeApp
//
//  Created by Cazacu Marius Constantin on 01.02.2026.
//

import SwiftUI
import SwiftData

@main
struct TimeAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Project.self,
            TimeEntry.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
