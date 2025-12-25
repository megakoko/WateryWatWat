import Foundation
import HealthKit

final class DefaultHealthKitService: HealthKitService, @unchecked Sendable {
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

    func saveDietaryWater(volume: Int64, date: Date, coreDataID: String) async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: Double(volume))

        let metadata: [String: Any] = [
            Constants.healthKitMetadataKey: coreDataID
        ]

        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: date, end: date, metadata: metadata)

        try await healthStore.save(sample)
    }

    func deleteAllRecords() async throws -> Int {
        let predicate = HKQuery.predicateForObjects(withMetadataKey: Constants.healthKitMetadataKey)

        let samples = try await querySamples(predicate: predicate, limit: HKObjectQueryNoLimit)

        guard !samples.isEmpty else {
            return 0
        }

        try await deleteSamples(samples)
        return samples.count
    }

    func deleteDietaryWater(coreDataID: String) async throws {
        let predicate = HKQuery.predicateForObjects(
            withMetadataKey: Constants.healthKitMetadataKey,
            operatorType: .equalTo,
            value: coreDataID
        )

        let samples = try await querySamples(predicate: predicate, limit: 1)

        guard let sample = samples.first else {
            return
        }

        try await deleteSamples([sample])
    }

    private func querySamples(predicate: NSPredicate, limit: Int) async throws -> [HKSample] {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: waterType,
                predicate: predicate,
                limit: limit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: samples ?? [])
            }

            healthStore.execute(query)
        }
    }

    private func deleteSamples(_ samples: [HKSample]) async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.delete(samples) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                if success {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: HealthKitError.deleteFailed)
                }
            }
        }
    }
}
