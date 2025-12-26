//
//  WateryWatWatApp.swift
//  WateryWatWat
//
//  Created by Andrey Chukavin on 18.12.2025.
//

import SwiftUI
import CoreData

@main
struct WateryWatWatApp: App {
    let persistenceController = PersistenceController.sharedApp
    let settingsService = DefaultSettingsService()
    let healthKitService = DefaultHealthKitService()

    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: ContentViewModel(
                    settingsService: settingsService,
                    persistenceController: persistenceController,
                    healthKitService: healthKitService
                )
            )
        }
    }
}
