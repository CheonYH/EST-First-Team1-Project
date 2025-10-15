//
//  EST_First_Team1_ProjectApp.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/14/25.
//

import SwiftUI
import SwiftData

@main
struct EST_First_Team1_ProjectApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            EntryModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            //
        }
        .modelContainer(sharedModelContainer)
    }
}
