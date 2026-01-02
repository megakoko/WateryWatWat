import Foundation
import CoreData

@Observable
final class ContentViewModel {
    var isGoalSet = false

    var goalViewModel: GoalViewModel?
    var mainViewModel: MainViewModel?

    private let settingsService: SettingsService
    private let persistenceController: PersistenceController
    private let healthKitService: HealthKitService

    init(settingsService: SettingsService, persistenceController: PersistenceController, healthKitService: HealthKitService) {
        self.settingsService = settingsService
        self.persistenceController = persistenceController
        self.healthKitService = healthKitService

        isGoalSet = settingsService.isGoalSet()

        if isGoalSet {
            initializeMainViewModel()
        } else {
            initializeGoalViewModel()
        }
    }

    private func initializeGoalViewModel() {
        let viewModel = GoalViewModel(settingsService: settingsService)
        viewModel.onComplete = { [weak self] in
            self?.isGoalSet = true
            self?.goalViewModel = nil
            self?.initializeMainViewModel()
        }
        self.goalViewModel = viewModel
    }

    private func initializeMainViewModel() {
        self.mainViewModel = MainViewModel(
            service: DefaultHydrationService(
                persistenceController: persistenceController,
                healthKitService: healthKitService,
                settingsService: settingsService
            ),
            settingsService: settingsService,
            notificationService: DefaultNotificationService(settingsService: settingsService),
            healthKitService: healthKitService
        )
    }
}
