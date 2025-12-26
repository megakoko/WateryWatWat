import Foundation

enum Gender: Hashable {
    case male
    case female
}

enum ActivityLevel: Hashable {
    case low
    case moderate
    case high
}

enum Climate: Hashable {
    case cold
    case warm
    case hot
}

enum AdditionalFactor {
    case coffee
    case exercise
}

struct AdditionalFactors {
    var coffee: Bool
    var exercise: Bool
}

struct GoalCalculationData {
    var weight: Int?
    var gender: Gender?
    var activityLevel: ActivityLevel?
    var climate: Climate?
    var additionalFactors = AdditionalFactors(coffee: false, exercise: false)
}

extension Gender {
    var icon: String {
        switch self {
        case .male: return "figure.arms.open"
        case .female: return "figure.dress.line.vertical.figure"
        }
    }

    var name: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }

    var description: String? {
        nil
    }
}

extension ActivityLevel {
    var icon: String {
        switch self {
        case .low: return "figure.walk"
        case .moderate: return "figure.walk.motion"
        case .high: return "figure.run"
        }
    }

    var name: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        }
    }

    var description: String? {
        switch self {
        case .low: return "Mostly sedentary"
        case .moderate: return "Light exercise"
        case .high: return "Active lifestyle"
        }
    }
}

extension Climate {
    var icon: String {
        switch self {
        case .cold: return "snowflake"
        case .warm: return "sun.max"
        case .hot: return "humidity"
        }
    }

    var name: String {
        switch self {
        case .cold: return "Cold"
        case .warm: return "Warm"
        case .hot: return "Hot/Humid"
        }
    }

    var description: String? {
        nil
    }
}

extension AdditionalFactor {
    var icon: String {
        switch self {
        case .coffee: return "cup.and.saucer.fill"
        case .exercise: return "figure.strengthtraining.traditional"
        }
    }

    var name: String {
        switch self {
        case .coffee: return "Regular coffee intake"
        case .exercise: return "Exercise > 60 min/day"
        }
    }

    var description: String? {
        nil
    }
}
