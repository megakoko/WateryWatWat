import Foundation

@Observable
final class SettingsViewModel: Identifiable {
    let id = UUID()
    var dailyGoal: Int64 = Constants.defaultDailyGoalML
    var isLoading = false

    private let service: SettingsServiceProtocol

    init(service: SettingsServiceProtocol) {
        self.service = service
    }

    func onAppear() async {
        dailyGoal = service.getDailyGoal()
    }

    func saveDailyGoal() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.setDailyGoal(dailyGoal)
        } catch {
        }
    }
}

extension SettingsViewModel: Hashable {
    static func == (lhs: SettingsViewModel, rhs: SettingsViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
