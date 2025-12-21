import Foundation
import Combine
import UserNotifications

protocol NotificationService {
    func requestPermission() async -> Bool
    func scheduleReminders(settings: ReminderSettings) async throws
    func cancelAllReminders() async
    func getNextScheduledReminder() async -> Date?
    func getAuthorizationStatus() async -> UNAuthorizationStatus
    var nextReminderTimePublisher: AnyPublisher<Date?, Never> { get }
}
