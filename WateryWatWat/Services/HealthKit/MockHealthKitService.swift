import Foundation

@Observable
final class MockHealthKitService: HealthKitServiceProtocol {
    private let delay: TimeInterval
    private let fail: Bool

    private(set) var isAuthorizationRequested = false
    private(set) var savedEntries: [(volume: Int64, date: Date)] = []
    private(set) var deleteCallCount = 0

    init(delay: TimeInterval, fail: Bool) {
        self.delay = delay
        self.fail = fail
    }

    func requestAuthorization() async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        isAuthorizationRequested = true
        if fail {
            throw HealthKitError.authorizationDenied
        }
    }

    func isAuthorized() async -> Bool {
        await Task.yield()
        return isAuthorizationRequested && !fail
    }

    func saveDietaryWater(volume: Int64, date: Date) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        if fail {
            throw HealthKitError.saveFailed
        }
        savedEntries.append((volume: volume, date: date))
    }

    func deleteAllRecords() async throws -> Int {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        deleteCallCount += 1
        if fail {
            throw HealthKitError.deleteFailed
        }
        let count = savedEntries.count
        savedEntries.removeAll()
        return count
    }
}

enum HealthKitError: LocalizedError {
    case authorizationDenied
    case saveFailed
    case deleteFailed
    case notAvailable

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "HealthKit authorization denied"
        case .saveFailed:
            return "Failed to save water entry to HealthKit"
        case .deleteFailed:
            return "Failed to delete HealthKit records"
        case .notAvailable:
            return "HealthKit is not available on this device"
        }
    }
}
