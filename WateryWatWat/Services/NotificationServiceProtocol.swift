import Foundation
import Combine

protocol NotificationService {
    func requestPermission() async -> Bool
    func scheduleReminders(settings: ReminderSettings) async throws
    func cancelAllReminders() async
    func getNextScheduledReminder() async -> Date?
    var nextReminderTimePublisher: AnyPublisher<Date?, Never> { get }
}
