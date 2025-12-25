import Foundation
import Combine

protocol SettingsService {
    func getDailyGoal() -> Int64
    func setDailyGoal(_ value: Int64)
    func getReminderSettings() -> ReminderSettings
    func setReminderEnabled(_ enabled: Bool)
    func setReminderStartTime(hour: Int, minute: Int)
    func setReminderEndTime(hour: Int, minute: Int)
    func setReminderPeriod(_ minutes: Int)
    func getNextReminderTime() -> Date?
    func getHealthSyncEnabled() -> Bool
    func setHealthSyncEnabled(_ enabled: Bool)
    func getStatsPeriod() -> StatsPeriod
    func setStatsPeriod(_ period: StatsPeriod)
    var reminderSettingsPublisher: AnyPublisher<Void, Never> { get }
}

final class DefaultSettingsService: SettingsService {
    private let defaults = UserDefaults.standard
    private let dailyGoalKey = "dailyGoalML"
    private let reminderEnabledKey = "remindersEnabled"
    private let reminderStartHourKey = "reminderStartHour"
    private let reminderStartMinuteKey = "reminderStartMinute"
    private let reminderEndHourKey = "reminderEndHour"
    private let reminderEndMinuteKey = "reminderEndMinute"
    private let reminderPeriodMinutesKey = "reminderPeriodMinutes"
    private let healthSyncEnabledKey = "healthSyncEnabled"
    private let statsPeriodDaysKey = "statsPeriodDays"

    var reminderSettingsPublisher: AnyPublisher<Void, Never> {
        Publishers.Merge6(
            UserDefaults.standard.publisher(for: \.remindersEnabled).map { _ in () },
            UserDefaults.standard.publisher(for: \.reminderStartHour).map { _ in () },
            UserDefaults.standard.publisher(for: \.reminderStartMinute).map { _ in () },
            UserDefaults.standard.publisher(for: \.reminderEndHour).map { _ in () },
            UserDefaults.standard.publisher(for: \.reminderEndMinute).map { _ in () },
            UserDefaults.standard.publisher(for: \.reminderPeriodMinutes).map { _ in () }
        )
        .eraseToAnyPublisher()
    }

    func getDailyGoal() -> Int64 {
        let goal = defaults.integer(forKey: dailyGoalKey)
        return goal > 0 ? Int64(goal) : Constants.defaultDailyGoalML
    }

    func setDailyGoal(_ value: Int64) {
        defaults.set(Int(value), forKey: dailyGoalKey)
    }

    func getReminderSettings() -> ReminderSettings {
        ReminderSettings(
            enabled: defaults.bool(forKey: reminderEnabledKey),
            startHour: defaults.object(forKey: reminderStartHourKey) as? Int ?? Constants.defaultReminderStartHour,
            startMinute: defaults.object(forKey: reminderStartMinuteKey) as? Int ?? Constants.defaultReminderStartMinute,
            endHour: defaults.object(forKey: reminderEndHourKey) as? Int ?? Constants.defaultReminderEndHour,
            endMinute: defaults.object(forKey: reminderEndMinuteKey) as? Int ?? Constants.defaultReminderEndMinute,
            periodMinutes: defaults.object(forKey: reminderPeriodMinutesKey) as? Int ?? Constants.defaultReminderPeriodMinutes
        )
    }

    func setReminderEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: reminderEnabledKey)
    }

    func setReminderStartTime(hour: Int, minute: Int) {
        defaults.set(hour, forKey: reminderStartHourKey)
        defaults.set(minute, forKey: reminderStartMinuteKey)
    }

    func setReminderEndTime(hour: Int, minute: Int) {
        defaults.set(hour, forKey: reminderEndHourKey)
        defaults.set(minute, forKey: reminderEndMinuteKey)
    }

    func setReminderPeriod(_ minutes: Int) {
        defaults.set(minutes, forKey: reminderPeriodMinutesKey)
    }

    func getNextReminderTime() -> Date? {
        let settings = getReminderSettings()
        guard settings.enabled && settings.isValid else { return nil }

        let calendar = Calendar.current
        let now = Date()
        let startTime = settings.startTime(for: now)
        let endTime = settings.endTime(for: now)

        guard startTime < endTime else { return nil }

        var current = startTime
        while current <= endTime {
            if current > now {
                return current
            }
            guard let next = calendar.date(byAdding: .minute, value: settings.periodMinutes, to: current) else { break }
            current = next
        }

        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        return settings.startTime(for: tomorrow)
    }

    func getHealthSyncEnabled() -> Bool {
        defaults.bool(forKey: healthSyncEnabledKey)
    }

    func setHealthSyncEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: healthSyncEnabledKey)
    }

    func getStatsPeriod() -> StatsPeriod {
        let days = defaults.integer(forKey: statsPeriodDaysKey)
        return StatsPeriod(rawValue: days) ?? .week
    }

    func setStatsPeriod(_ period: StatsPeriod) {
        defaults.set(period.days, forKey: statsPeriodDaysKey)
    }
}
