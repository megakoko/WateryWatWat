import Foundation
import CoreData

@Observable
final class MainViewModel {
    var todayTotal: Int64 = 0
    var dailyTotals: [Date: Int64] = [:]
    var dailyGoal: Int64 = Constants.defaultDailyGoalML
    var streak: Int = 0
    var recentEntries: [GroupedHydrationEntries] = []
    var addEntryViewModel: AddEntryViewModel?
    var settingsViewModel: SettingsViewModel?
    var historyViewModel: HistoryViewModel?

    var progress: Double {
        Double(todayTotal) / Double(dailyGoal)
    }

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

    func showHistory() {
        historyViewModel = HistoryViewModel(service: service)
    }

    private func loadData() async {
        async let todayTask: Void = fetchTodayTotal()
        async let historyTask: Void = fetchSevenDayHistory()
        async let goalTask: Void = fetchDailyGoal()
        async let streakTask: Void = fetchStreak()
        async let recentTask: Void = fetchRecentEntries()

        _ = await (todayTask, historyTask, goalTask, streakTask, recentTask)
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

    private func fetchStreak() async {
        do {
            streak = try await service.calculateStreak(goal: dailyGoal)
        } catch {
            streak = 0
        }
    }

    private func fetchRecentEntries() async {
        do {
            let calendar = Calendar.current
            let endDate = calendar.startOfDay(for: Date())
            let startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!

            let entries = try await service.fetchEntries(from: startDate, to: endDate)

            var grouped: [Date: [HydrationEntry]] = [:]
            for entry in entries {
                let dayStart = calendar.startOfDay(for: entry.date!)
                grouped[dayStart, default: []].append(entry)
            }

            recentEntries = grouped.map { date, entries in
                GroupedHydrationEntries(date: date, entries: entries.reversed())
            }.sorted { $0.date < $1.date }
        } catch {
            recentEntries = []
        }
    }
}
