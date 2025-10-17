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
            CategoryModel.self,
            
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
            // 앱의 루트 뷰를 지정하세요. 현재 카테고리 화면을 띄우도록 설정합니다.
            MainPage()
        }
        .modelContainer(sharedModelContainer)
    }
}
