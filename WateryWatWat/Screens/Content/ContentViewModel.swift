import Foundation
import CoreData
import Combine
import SwiftUI

@Observable
final class ContentViewModel {
    var isGoalSet = false
    var showCongratulations = false

    var goalViewModel: GoalViewModel?
    var mainViewModel: MainViewModel?

    var confettiPublisher: AnyPublisher<Void, Never> {
        _confettiPublisher.eraseToAnyPublisher()
    }

    private let settingsService: SettingsService
    private let persistenceController: PersistenceController
    private let healthKitService: HealthKitService
    private var cancellables = Set<AnyCancellable>()
    private var _confettiPublisher = PassthroughSubject<Void, Never>()
    private var previousTotal: Int64 = 0
    private var previousGoal: Int64 = 0
    private var observationTask: Task<Void, Never>?

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

    deinit {
        observationTask?.cancel()
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
        let mainViewModel = MainViewModel(
            service: DefaultHydrationService(
                persistenceController: persistenceController,
                healthKitService: healthKitService,
                settingsService: settingsService
            ),
            settingsService: settingsService,
            notificationService: DefaultNotificationService(settingsService: settingsService),
            healthKitService: healthKitService
        )

        self.mainViewModel = mainViewModel

        observationTask = Task { @MainActor in
            while !Task.isCancelled {
                await Task.yield()
                let currentTotal = mainViewModel.todayTotal
                let currentGoal = mainViewModel.dailyGoal

                if currentTotal != previousTotal || currentGoal != previousGoal {
                    checkGoalReached(
                        todayTotal: currentTotal,
                        dailyGoal: currentGoal,
                        previousTotal: previousTotal,
                        previousGoal: previousGoal
                    )

                    previousTotal = currentTotal
                    previousGoal = currentGoal
                }

                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }

    private func checkGoalReached(todayTotal: Int64, dailyGoal: Int64, previousTotal: Int64, previousGoal: Int64) {
        guard dailyGoal == previousGoal,
              previousTotal > 0,
              previousTotal < dailyGoal,
              todayTotal >= dailyGoal else {
            return
        }

        onGoalReached()
    }

    private func onGoalReached() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self._confettiPublisher.send(())

            withAnimation(.easeOut(duration: 0.2)) {
                self.showCongratulations = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.easeInOut(duration: 1)) {
                    self.showCongratulations = false
                }
            }
        }
    }
}
