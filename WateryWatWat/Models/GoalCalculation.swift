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
        case .male: return "gender.male".localized
        case .female: return "gender.female".localized
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
        case .low: return "activityLevel.low".localized
        case .moderate: return "activityLevel.moderate".localized
        case .high: return "activityLevel.high".localized
        }
    }

    var description: String? {
        switch self {
        case .low: return "activityLevel.low.description".localized
        case .moderate: return "activityLevel.moderate.description".localized
        case .high: return "activityLevel.high.description".localized
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
        case .cold: return "climate.cold".localized
        case .warm: return "climate.warm".localized
        case .hot: return "climate.hot".localized
        }
    }

    var description: String? {
        switch self {
        case .cold: return "climate.cold.description".localized
        case .warm: return "climate.warm.description".localized
        case .hot: return "climate.hot.description".localized
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
        case .coffee: return "additionalFactor.coffee.name".localized
        case .exercise: return "additionalFactor.exercise.name".localized
        }
    }

    var description: String? {
        switch self {
        case .coffee: return "additionalFactor.coffee.description".localized
        case .exercise: return "additionalFactor.exercise.description".localized
        }
    }
}
