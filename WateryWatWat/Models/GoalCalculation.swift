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
        case .male: return "figure.stand"
        case .female: return "figure.stand.dress"
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
        case .low: return "Sedentary"
        case .moderate: return "Active"
        case .high: return "Intense exercise"
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
        case .cold: return "Cold/Temperate"
        case .warm: return "Warm"
        case .hot: return "Hot/Humid"
        }
    }

    var description: String? {
        switch self {
        case .cold: return "< 20°C"
        case .warm: return "20-30°C"
        case .hot: return "30°C+"
        }
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
        switch self {
        case .coffee: return "Diuretic effect"
        case .exercise: return "Requires more hydration"
        }
    }
}
