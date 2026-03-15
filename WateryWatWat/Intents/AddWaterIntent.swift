import AppIntents
import CoreData
import Foundation
import SwiftUI

// MARK: - AddWaterIntent

struct AddWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Water"
    static var description = IntentDescription("Log water intake")

    static var openAppWhenRun: Bool = false
    static var isDiscoverable: Bool = true

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$volume)")
    }

    @Parameter(title: "Volume")
    var volume: Measurement<UnitVolume>

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let volumeInML = Int64(volume.converted(to: .milliliters).value)

        let healthKitService = DefaultHealthKitService()
        let settingsService = DefaultSettingsService()
        let service = DefaultHydrationService(
            persistenceController: PersistenceController.sharedApp,
            healthKitService: healthKitService,
            settingsService: settingsService
        )
        try await service.addEntry(volume: volumeInML, type: .water, date: Date())

        let todayTotal = try await service.fetchTodayTotal()

        return .result(
            dialog: "Added \(volumeInML) mL. Today's total: \(todayTotal) mL",
            view: AddWaterResultView(addedVolume: volumeInML, todayTotal: todayTotal)
        )
    }
}

// MARK: - AddWaterResultView

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
