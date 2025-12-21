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
    let persistenceController = PersistenceController.shared
    let settingsService = SettingsService()

    var body: some Scene {
        WindowGroup {
            MainView(
                viewModel: MainViewModel(
                    service: HydrationService(context: persistenceController.container.viewContext),
                    settingsService: settingsService,
                    notificationService: DefaultNotificationService(settingsService: settingsService)
                )
            )
        }
    }
}
