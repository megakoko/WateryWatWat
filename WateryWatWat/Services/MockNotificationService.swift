import Foundation
import Combine
import UserNotifications

final class MockNotificationService {
    private let delay: TimeInterval
    private let fail: Bool
    private var permissionGranted = true
    private var scheduledReminders: [Date] = []
    private let nextReminderSubject = CurrentValueSubject<Date?, Never>(nil)

    var nextReminderTimePublisher: AnyPublisher<Date?, Never> {
        nextReminderSubject.eraseToAnyPublisher()
    }

    init(delay: TimeInterval = 0, fail: Bool = false) {
        self.delay = delay
        self.fail = fail
    }
}

extension MockNotificationService: NotificationService {
    func requestPermission() async -> Bool {
        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        return fail ? false : permissionGranted
    }

    func scheduleReminders(settings: ReminderSettings) async throws {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        if fail {
            throw NSError(domain: "MockNotificationService", code: -1)
        }

        guard settings.enabled && settings.isValid else {
            scheduledReminders = []
            nextReminderSubject.send(nil)
            return
        }

        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!

        scheduledReminders = calculateMockTimes(settings: settings, date: now, fromNow: true)
            + calculateMockTimes(settings: settings, date: tomorrow, fromNow: false)

        nextReminderSubject.send(scheduledReminders.min())
    }

    func cancelAllReminders() async {
        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        scheduledReminders = []
        nextReminderSubject.send(nil)
    }

    func getNextScheduledReminder() async -> Date? {
        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        return scheduledReminders.min()
    }

    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        return permissionGranted ? .authorized : .denied
    }
}

private extension MockNotificationService {
    func calculateMockTimes(settings: ReminderSettings, date: Date, fromNow: Bool) -> [Date] {
        let calendar = Calendar.current
        let startTime = settings.startTime(for: date)
        let endTime = settings.endTime(for: date)

        guard startTime < endTime else { return [] }

        var times: [Date] = []
        var current = startTime
        let now = Date()

        while current <= endTime {
            if !fromNow || current > now {
                times.append(current)
            }
            guard let next = calendar.date(byAdding: .minute, value: settings.periodMinutes, to: current) else { break }
            current = next
        }

        return times
    }
}
