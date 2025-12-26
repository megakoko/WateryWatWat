import Foundation

enum GoalPage {
    case intro
    case weight
    case gender
    case activity
    case climate
    case factors
    case result
}

@Observable
final class GoalViewModel: Identifiable {
    let id = UUID()
    var currentPage: GoalPage = .intro
    var data = GoalCalculationData()
    var adjustedGoal: Int64 = 2000

    private let volumeFormatter = VolumeFormatter(unit: .liters)

    var canGoNext: Bool {
        switch currentPage {
        case .intro:
            return true
        case .weight:
            return data.weight != nil
        case .gender:
            return data.gender != nil
        case .activity:
            return data.activityLevel != nil
        case .climate:
            return data.climate != nil
        case .factors:
            return true
        case .result:
            return false
        }
    }

    var calculatedGoal: Int64 {
        2000
    }

    var formattedGoal: String {
        volumeFormatter.string(from: adjustedGoal)
    }

    func nextPage() {
        guard canGoNext else { return }

        switch currentPage {
        case .intro:
            currentPage = .weight
        case .weight:
            currentPage = .gender
        case .gender:
            currentPage = .activity
        case .activity:
            currentPage = .climate
        case .climate:
            currentPage = .factors
        case .factors:
            adjustedGoal = calculatedGoal
            currentPage = .result
        case .result:
            break
        }
    }

    func previousPage() {
        switch currentPage {
        case .intro:
            break
        case .weight:
            currentPage = .intro
        case .gender:
            currentPage = .weight
        case .activity:
            currentPage = .gender
        case .climate:
            currentPage = .activity
        case .factors:
            currentPage = .climate
        case .result:
            currentPage = .factors
        }
    }
}

extension GoalViewModel: Hashable {
    static func == (lhs: GoalViewModel, rhs: GoalViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
