//
//  Persistence.swift
//  WateryWatWat
//
//  Created by Andrey Chukavin on 18.12.2025.
//

import CoreData

struct PersistenceController {
    static let sharedApp = PersistenceController(useCloudKit: true)
    static let sharedWidget = PersistenceController(useCloudKit: false)

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true, useCloudKit: false)
        let viewContext = result.container.viewContext
        for _ in 0..<7 {
            let entry = HydrationEntry(context: viewContext)
            entry.date = Date().addingTimeInterval(-TimeInterval.random(in: 0...604800))
            entry.volume = Int64.random(in: 500...2500)
            entry.type = "water"
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false, useCloudKit: Bool) {
        container = NSPersistentCloudKitContainer(name: "WateryWatWat")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            guard let description = container.persistentStoreDescriptions.first else {
                fatalError("No persistent store description")
            }

            if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) {
                description.url = groupURL.appendingPathComponent("WateryWatWat.sqlite")
            }

            if useCloudKit {
                description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.chukavin.WateryWatWat")
            }
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
