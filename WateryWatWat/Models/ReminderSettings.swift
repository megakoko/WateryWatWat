import Foundation

struct ReminderSettings {
    let enabled: Bool
    let startHour: Int
    let startMinute: Int
    let endHour: Int
    let endMinute: Int
    let periodMinutes: Int

    var isValid: Bool {
        let calendar = Calendar.current
        let start = startTime(for: Date())
        let end = endTime(for: Date())
        return start < end && periodMinutes >= Constants.minReminderPeriodMinutes && periodMinutes <= Constants.maxReminderPeriodMinutes
    }

    func startTime(for date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = startHour
        components.minute = startMinute
        return calendar.date(from: components) ?? date
    }

    func endTime(for date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = endHour
        components.minute = endMinute
        return calendar.date(from: components) ?? date
    }
}
