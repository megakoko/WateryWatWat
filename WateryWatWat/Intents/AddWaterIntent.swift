import Foundation
import AppIntents
import SwiftUI
import CoreData

struct AddWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Water"
    static var description = IntentDescription("Log water intake")

    static var openAppWhenRun: Bool = false
    static var isDiscoverable: Bool = true

    @Parameter(title: "Volume")
    var volume: Measurement<UnitVolume>

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$volume)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let volumeInML = Int64(volume.converted(to: .milliliters).value)

        let healthKitService = DefaultHealthKitService()
        let settingsService = DefaultSettingsService()
        let service = DefaultHydrationService(
            context: PersistenceController.sharedApp.container.viewContext,
            healthKitService: healthKitService,
            settingsService: settingsService
        )
        try await service.addEntry(volume: volumeInML, type: "water", date: Date())

        let todayTotal = try await service.fetchTodayTotal()

        return .result(
            dialog: "Added \(volumeInML) mL. Today's total: \(todayTotal) mL",
            view: AddWaterResultView(addedVolume: volumeInML, todayTotal: todayTotal)
        )
    }
}

struct AddWaterResultView: View {
    let addedVolume: Int64
    let todayTotal: Int64

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.blue)
                Text("+\(addedVolume) mL")
                    .font(.headline)
            }
            Text("Total: \(todayTotal) mL")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
