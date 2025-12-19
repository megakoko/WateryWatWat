import Foundation
import CoreData

@Observable
final class MainViewModel {
    var todayTotal: Int64 = 0
    var dailyTotals: [Date: Int64] = [:]
    var dailyGoal: Int64 = Constants.defaultDailyGoalML
    var addEntryViewModel: AddEntryViewModel?
    var settingsViewModel: SettingsViewModel?

    private let service: HydrationServiceProtocol
    private let settingsService: SettingsServiceProtocol

    init(service: HydrationServiceProtocol, settingsService: SettingsServiceProtocol) {
        self.service = service
        self.settingsService = settingsService

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSPersistentStoreRemoteChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.loadData()
            }
        }
    }

    func onAppear() async {
        await loadData()
    }

    func showAddEntry() {
        addEntryViewModel = AddEntryViewModel(service: service)
    }

    func onEntryAdded() {
        addEntryViewModel = nil
        Task {
            await loadData()
        }
    }

    func showSettings() {
        settingsViewModel = SettingsViewModel(service: settingsService)
    }

    func onSettingsDismissed() {
        settingsViewModel = nil
        Task {
            await loadData()
        }
    }

    private func loadData() async {
        async let todayTask: Void = fetchTodayTotal()
        async let historyTask: Void = fetchSevenDayHistory()
        async let goalTask: Void = fetchDailyGoal()

        _ = await (todayTask, historyTask, goalTask)
    }

    private func fetchDailyGoal() async {
        dailyGoal = settingsService.getDailyGoal()
    }

    private func fetchTodayTotal() async {
        do {
            todayTotal = try await service.fetchTodayTotal()
        } catch {
            todayTotal = 0
        }
    }

    private func fetchSevenDayHistory() async {
        do {
            let calendar = Calendar.current
            let endDate = calendar.startOfDay(for: Date())
            let startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!

            dailyTotals = try await service.fetchDailyTotals(from: startDate, to: endDate)
        } catch {
            dailyTotals = [:]
        }
    }
}
