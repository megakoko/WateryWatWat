import Foundation

extension UserDefaults {
    @objc dynamic var dailyGoalML: Int {
        integer(forKey: "dailyGoalML")
    }
}
