import Foundation

extension UserDefaults {
    @objc dynamic var dailyGoalML: Int {
        integer(forKey: "dailyGoalML")
    }

    @objc dynamic var remindersEnabled: Bool {
        bool(forKey: "remindersEnabled")
    }

    @objc dynamic var reminderStartHour: Int {
        integer(forKey: "reminderStartHour")
    }

    @objc dynamic var reminderStartMinute: Int {
        integer(forKey: "reminderStartMinute")
    }

    @objc dynamic var reminderEndHour: Int {
        integer(forKey: "reminderEndHour")
    }

    @objc dynamic var reminderEndMinute: Int {
        integer(forKey: "reminderEndMinute")
    }

    @objc dynamic var reminderPeriodMinutes: Int {
        integer(forKey: "reminderPeriodMinutes")
    }
}
