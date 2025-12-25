import Foundation
import HealthKit

final class HealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    private let healthStore = HKHealthStore()
    private let waterType = HKQuantityType(.dietaryWater)

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        let types: Set<HKSampleType> = [waterType]

        try await healthStore.requestAuthorization(toShare: types, read: [])
    }

    func isAuthorized() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }

        let status = healthStore.authorizationStatus(for: waterType)
        return status == .sharingAuthorized
    }

    func saveDietaryWater(volume: Int64, date: Date) async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: Double(volume))
        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: date, end: date)

        try await healthStore.save(sample)
    }

    func deleteAllRecords() async throws -> Int {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            throw HealthKitError.deleteFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: waterType,
                predicate: nil,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { [weak self] _, samples, error in
                guard let self = self else {
                    continuation.resume(throwing: HealthKitError.deleteFailed)
                    return
                }

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let samples = samples, !samples.isEmpty else {
                    continuation.resume(returning: 0)
                    return
                }

                let appSamples = samples.filter { sample in
                    sample.sourceRevision.source.bundleIdentifier == bundleIdentifier
                }

                guard !appSamples.isEmpty else {
                    continuation.resume(returning: 0)
                    return
                }

                let deletedCount = appSamples.count

                self.healthStore.delete(appSamples) { success, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    if success {
                        continuation.resume(returning: deletedCount)
                    } else {
                        continuation.resume(throwing: HealthKitError.deleteFailed)
                    }
                }
            }

            healthStore.execute(query)
        }
    }
}
