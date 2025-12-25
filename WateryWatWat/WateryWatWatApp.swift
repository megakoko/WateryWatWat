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
    let settingsService = SettingsService()
    let healthKitService = HealthKitService()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainView(
                    viewModel: MainViewModel(
                        service: HydrationService(context: persistenceController.container.viewContext, healthKitService: healthKitService, settingsService: settingsService),
                        settingsService: settingsService,
                        notificationService: DefaultNotificationService(settingsService: settingsService),
                        healthKitService: healthKitService
                    )
                )
            }
        }
    }
}
