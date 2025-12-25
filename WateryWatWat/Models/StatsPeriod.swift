import Foundation

enum StatsPeriod: Int {
    case week = 7
    case month = 30

    var days: Int {
        rawValue
    }

    func toggled() -> StatsPeriod {
        self == .week ? .month : .week
    }
}
