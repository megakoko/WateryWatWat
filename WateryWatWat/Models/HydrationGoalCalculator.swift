import Foundation

struct HydrationGoalCalculator {
    static func calculate(
        weightKg: Double,
        gender: Gender,
        activity: ActivityLevel,
        climate: Climate,
        caffeine: Bool,
        longExercise: Bool
    ) -> Int64 {
        var total = weightKg * 30.0
        total *= gender.multiplier
        total *= activity.multiplier
        total *= climate.multiplier

        if caffeine { total += 250 }
        if longExercise { total += 500 }

        return Int64((total / 100).rounded() * 100)
    }
}

extension Gender {
    var multiplier: Double {
        switch self {
        case .male: return 1.0
        case .female: return 0.9
        }
    }
}

extension ActivityLevel {
    var multiplier: Double {
        switch self {
        case .low: return 1.0
        case .moderate: return 1.2
        case .high: return 1.4
        }
    }
}

extension Climate {
    var multiplier: Double {
        switch self {
        case .cold: return 1.0
        case .warm: return 1.1
        case .hot: return 1.3
        }
    }
}
