import Foundation
import CoreData

@Observable
final class ContentViewModel {
    var isGoalSet = false

    let goalViewModel: GoalViewModel
    let mainViewModel: MainViewModel

    private let settingsService: SettingsService

    init(settingsService: SettingsService, persistenceController: PersistenceController, healthKitService: HealthKitService) {
        self.settingsService = settingsService
        self.goalViewModel = GoalViewModel(settingsService: settingsService)
        self.mainViewModel = MainViewModel(
            service: DefaultHydrationService(
                context: persistenceController.container.viewContext,
                healthKitService: healthKitService,
                settingsService: settingsService
            ),
            settingsService: settingsService,
            notificationService: DefaultNotificationService(settingsService: settingsService),
            healthKitService: healthKitService
        )
        self.goalViewModel.onComplete = { [weak self] in
            self?.isGoalSet = true
        }
        isGoalSet = settingsService.isGoalSet()
    }
}
