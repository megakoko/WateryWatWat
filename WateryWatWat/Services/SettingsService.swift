import Foundation

protocol SettingsServiceProtocol {
    func getDailyGoal() -> Int64
    func setDailyGoal(_ value: Int64) async throws
}

final class SettingsService: SettingsServiceProtocol {
    private let defaults = UserDefaults.standard
    private let dailyGoalKey = "dailyGoalML"

    func getDailyGoal() -> Int64 {
        let goal = defaults.integer(forKey: dailyGoalKey)
        return goal > 0 ? Int64(goal) : Constants.defaultDailyGoalML
    }

    func setDailyGoal(_ value: Int64) async throws {
        defaults.set(Int(value), forKey: dailyGoalKey)
    }
}
