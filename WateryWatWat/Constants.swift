import Foundation

enum Constants {
    static let defaultDailyGoalML: Int64 = 2000
    static let minGoalML: Int64 = 500
    static let maxGoalML: Int64 = 5000
    static let stepGoalML: Int64 = 100

    static let defaultReminderStartHour = 8
    static let defaultReminderStartMinute = 0
    static let defaultReminderEndHour = 22
    static let defaultReminderEndMinute = 0
    static let defaultReminderPeriodMinutes = 60
    static let minReminderPeriodMinutes = 30
    static let maxReminderPeriodMinutes = 240
    static let stepReminderPeriodMinutes = 30

    static let notificationIdentifierPrefix = "hydration_"
    static let notificationCategoryId = "HYDRATION_REMINDER"

    static let standardVolumes: [Int64] = [200, 300, 500, 750, 1000, 1500]
}
