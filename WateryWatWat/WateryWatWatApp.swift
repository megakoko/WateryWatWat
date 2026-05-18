//
//  WateryWatWatApp.swift
//  WateryWatWat
//
//  Created by Andrey Chukavin on 18.12.2025.
//

import AppIntents
import CoreData
import SwiftUI

// swiftformat:disable organizeDeclarations
@main
struct WateryWatWatApp: App {
    let persistenceController = PersistenceController.sharedApp
    let settingsService = DefaultSettingsService()
    let healthKitService = DefaultHealthKitService()

    init() {
        WateryWatWatShortcuts.updateAppShortcutParameters()
    }

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

// swiftformat:enable organizeDeclarations
