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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
