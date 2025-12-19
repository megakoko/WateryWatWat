import Foundation

final class MockSettingsService: SettingsServiceProtocol {
    private let delay: TimeInterval
    private let fail: Bool
    private var storedGoal: Int64 = Constants.defaultDailyGoalML

    init(delay: TimeInterval = 0, fail: Bool = false) {
        self.delay = delay
        self.fail = fail
    }

    func getDailyGoal() -> Int64 {
        return storedGoal
    }

    func setDailyGoal(_ value: Int64) async throws {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }

        if fail {
            throw NSError(domain: "MockSettingsService", code: -1)
        }

        storedGoal = value
    }
}
