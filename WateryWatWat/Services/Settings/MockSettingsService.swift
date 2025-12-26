import Foundation
import Combine

final class MockSettingsService: SettingsService {
    private let delay: TimeInterval
    private let fail: Bool
    private var storedGoal: Int64 = Constants.defaultDailyGoalML
    private var storedReminderSettings = ReminderSettings(
        enabled: false,
        startHour: Constants.defaultReminderStartHour,
        startMinute: Constants.defaultReminderStartMinute,
        endHour: Constants.defaultReminderEndHour,
        endMinute: Constants.defaultReminderEndMinute,
        periodMinutes: Constants.defaultReminderPeriodMinutes
    )
    private let reminderSettingsSubject = PassthroughSubject<Void, Never>()
    private var healthSyncEnabled = false
    private var statsPeriod: StatsPeriod = .week

    var reminderSettingsPublisher: AnyPublisher<Void, Never> {
        reminderSettingsSubject.eraseToAnyPublisher()
    }

    init(delay: TimeInterval = 0, fail: Bool = false) {
        self.delay = delay
        self.fail = fail
    }

    func getDailyGoal() -> Int64 {
        return storedGoal
    }

    func setDailyGoal(_ value: Int64) {
        storedGoal = value
    }

    func isGoalSet() -> Bool {
        storedGoal != Constants.defaultDailyGoalML
    }

    func getReminderSettings() -> ReminderSettings {
        return storedReminderSettings
    }

    func setReminderEnabled(_ enabled: Bool) {
        storedReminderSettings = ReminderSettings(
            enabled: enabled,
            startHour: storedReminderSettings.startHour,
            startMinute: storedReminderSettings.startMinute,
            endHour: storedReminderSettings.endHour,
            endMinute: storedReminderSettings.endMinute,
            periodMinutes: storedReminderSettings.periodMinutes
        )
        reminderSettingsSubject.send()
    }

    func setReminderStartTime(hour: Int, minute: Int) {
        storedReminderSettings = ReminderSettings(
            enabled: storedReminderSettings.enabled,
            startHour: hour,
            startMinute: minute,
            endHour: storedReminderSettings.endHour,
            endMinute: storedReminderSettings.endMinute,
            periodMinutes: storedReminderSettings.periodMinutes
        )
        reminderSettingsSubject.send()
    }

    func setReminderEndTime(hour: Int, minute: Int) {
        storedReminderSettings = ReminderSettings(
            enabled: storedReminderSettings.enabled,
            startHour: storedReminderSettings.startHour,
            startMinute: storedReminderSettings.startMinute,
            endHour: hour,
            endMinute: minute,
            periodMinutes: storedReminderSettings.periodMinutes
        )
        reminderSettingsSubject.send()
    }

    func setReminderPeriod(_ minutes: Int) {
        storedReminderSettings = ReminderSettings(
            enabled: storedReminderSettings.enabled,
            startHour: storedReminderSettings.startHour,
            startMinute: storedReminderSettings.startMinute,
            endHour: storedReminderSettings.endHour,
            endMinute: storedReminderSettings.endMinute,
            periodMinutes: minutes
        )
        reminderSettingsSubject.send()
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
        healthSyncEnabled
    }

    func setHealthSyncEnabled(_ enabled: Bool) {
        healthSyncEnabled = enabled
    }

    func getStatsPeriod() -> StatsPeriod {
        statsPeriod
    }

    func setStatsPeriod(_ period: StatsPeriod) {
        statsPeriod = period
    }
}
