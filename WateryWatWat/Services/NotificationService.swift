import Foundation
import UserNotifications
import Combine

final class DefaultNotificationService {
    private let notificationCenter = UNUserNotificationCenter.current()
    private let settingsService: SettingsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private let nextReminderSubject = CurrentValueSubject<Date?, Never>(nil)

    var nextReminderTimePublisher: AnyPublisher<Date?, Never> {
        nextReminderSubject.eraseToAnyPublisher()
    }

    init(settingsService: SettingsServiceProtocol) {
        self.settingsService = settingsService

        settingsService.reminderSettingsPublisher
            .sink { [weak self] _ in
                Task {
                    await self?.updateNextReminder()
                }
            }
            .store(in: &cancellables)
    }

    private func updateNextReminder() async {
        let settings = settingsService.getReminderSettings()
        guard settings.enabled else {
            nextReminderSubject.send(nil)
            return
        }

        do {
            try await scheduleReminders(settings: settings)
            let nextTime = await getNextScheduledReminder()
            nextReminderSubject.send(nextTime)
        } catch {
            nextReminderSubject.send(nil)
        }
    }
}

extension DefaultNotificationService: NotificationService {
    func requestPermission() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleReminders(settings: ReminderSettings) async throws {
        guard settings.enabled && settings.isValid else {
            await cancelAllReminders()
            return
        }

        await cancelAllReminders()

        let calendar = Calendar.current
        let now = Date()

        let todayTimes = calculateReminderTimes(
            settings: settings,
            date: now,
            fromNow: true
        )

        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let tomorrowTimes = calculateReminderTimes(
            settings: settings,
            date: tomorrow,
            fromNow: false
        )

        let allTimes = todayTimes + tomorrowTimes

        for time in allTimes {
            let content = UNMutableNotificationContent()
            content.title = "Hydration Reminder"
            content.body = HydrationMessages.motivational.randomElement() ?? "Time to drink some water!"
            content.sound = .default
            content.categoryIdentifier = Constants.notificationCategoryId

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(
                identifier: "\(Constants.notificationIdentifierPrefix)\(time.timeIntervalSince1970)",
                content: content,
                trigger: trigger
            )

            try await notificationCenter.add(request)
        }

        let nextTime = await getNextScheduledReminder()
        nextReminderSubject.send(nextTime)
    }

    func cancelAllReminders() async {
        notificationCenter.removeAllPendingNotificationRequests()
        nextReminderSubject.send(nil)
    }

    func getNextScheduledReminder() async -> Date? {
        let requests = await notificationCenter.pendingNotificationRequests()
        let hydrationRequests = requests.filter { $0.identifier.hasPrefix(Constants.notificationIdentifierPrefix) }

        let dates = hydrationRequests.compactMap { request -> Date? in
            guard let trigger = request.trigger as? UNCalendarNotificationTrigger else { return nil }
            return Calendar.current.date(from: trigger.dateComponents)
        }

        return dates.min()
    }

    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
}

private extension DefaultNotificationService {
    func calculateReminderTimes(
        settings: ReminderSettings,
        date: Date,
        fromNow: Bool
    ) -> [Date] {
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
