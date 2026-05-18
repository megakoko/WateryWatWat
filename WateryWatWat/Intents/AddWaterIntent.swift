import AppIntents
import CoreData
import Foundation
import SwiftUI

// MARK: - WaterAmountEntity

struct WaterAmountEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Water Amount"
    static var defaultQuery = WaterAmountQuery()

    let id: Int

    var volumeML: Int64 {
        Int64(id)
    }

    var displayRepresentation: DisplayRepresentation {
        let formatter = VolumeFormatter(unit: .milliliters, minimumFractionDigits: 0)
        return DisplayRepresentation(title: "\(formatter.string(from: volumeML))")
    }
}

// MARK: - WaterAmountQuery

struct WaterAmountQuery: EntityQuery {
    func entities(for identifiers: [Int]) async throws -> [WaterAmountEntity] {
        let all = try await allVolumes()
        return all.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [WaterAmountEntity] {
        try await allVolumes()
    }

    private func allVolumes() async throws -> [WaterAmountEntity] {
        let service = DefaultHydrationService(
            persistenceController: PersistenceController.sharedApp,
            healthKitService: DefaultHealthKitService(),
            settingsService: DefaultSettingsService()
        )
        let frequent = try await service.fetchFrequentVolumes(excluding: Constants.standardVolumes, limit: 3)
        return (Constants.standardVolumes + frequent).sorted().map { WaterAmountEntity(id: Int($0)) }
    }
}

// MARK: - LogWaterWithAmountIntent

struct LogWaterWithAmountIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Water (Pick Amount)"
    static var description = IntentDescription("Log water intake by choosing from preset amounts")

    static var openAppWhenRun: Bool = false
    static var isDiscoverable: Bool = true

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$amount) of water")
    }

    @Parameter(title: "Amount", requestValueDialog: IntentDialog("How much water did you drink?"))
    var amount: WaterAmountEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let volumeInML = amount.volumeML

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
