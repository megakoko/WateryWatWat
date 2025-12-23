import Foundation
import CoreData
import Combine
import SwiftUI
import WidgetKit

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
    var nextReminderTime: Date?
    var statsPeriodDays: Int = 7
    var thirtyDayTotals: [Date: Int64] = [:]

    var progress: Double {
        Double(todayTotal) / Double(dailyGoal)
    }

    var remainingToGoal: Int64 {
        max(0, dailyGoal - todayTotal)
    }

    var averageIntake: Int64 {
        let totals = statsPeriodDays == 7 ? dailyTotals : thirtyDayTotals
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -(statsPeriodDays - 1), to: endDate)!

        var total: Int64 = 0
        var currentDate = startDate
        while currentDate <= endDate {
            total += totals[currentDate] ?? 0
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return total / Int64(statsPeriodDays)
    }

    var goalHitRate: Int {
        let totals = statsPeriodDays == 7 ? dailyTotals : thirtyDayTotals
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -(statsPeriodDays - 1), to: endDate)!

        var daysMetGoal = 0
        var currentDate = startDate
        while currentDate <= endDate {
            if (totals[currentDate] ?? 0) >= dailyGoal {
                daysMetGoal += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return Int((Double(daysMetGoal) / Double(statsPeriodDays)) * 100)
    }

    func toggleStatsPeriod() {
        statsPeriodDays = statsPeriodDays == 7 ? 30 : 7
    }

    var streakText: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day]

        let components = DateComponents(day: streak)
        return formatter.string(from: components)!
    }

    private let service: HydrationServiceProtocol
    private let settingsService: SettingsServiceProtocol
    private let notificationService: NotificationService
    private let notificationDelegate = NotificationDelegate()
    private var cancellables = Set<AnyCancellable>()
    private var midnightTimer: Timer?
    private var lastRefreshDate: Date = Date()

    init(service: HydrationServiceProtocol, settingsService: SettingsServiceProtocol, notificationService: NotificationService) {
        self.service = service
        self.settingsService = settingsService
        self.notificationService = notificationService

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSPersistentStoreRemoteChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.loadData()
                self?.reloadWidgets()
            }
        }

        UserDefaults.standard.publisher(for: \.dailyGoalML)
            .sink { [weak self] _ in
                Task {
                    await self?.fetchDailyGoal()
                    await self?.fetchStreak()
                }
            }
            .store(in: &cancellables)

        notificationService.nextReminderTimePublisher
            .sink { [weak self] nextTime in
                self?.nextReminderTime = nextTime
            }
            .store(in: &cancellables)
    }

    deinit {
        midnightTimer?.invalidate()
    }

    func onAppear() async {
        await loadData()
        await updateReminders()
        scheduleMidnightRefresh()
        setupNotificationDelegate()
    }
    
    private func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        notificationDelegate.onNotificationTap = { [weak self] in
            self?.handleNotificationTap()
        }
    }

    private func handleNotificationTap() {
        showAddEntry()
    }

    func showAddEntry() {
        addEntryViewModel = AddEntryViewModel(service: service)
    }

    func quickAddEntry(volume: Int64) {
        Task {
            await addQuickEntry(volume: volume)
        }
    }

    private func addQuickEntry(volume: Int64) async {
        do {
            try await service.addEntry(volume: volume, type: "water", date: Date())
            await loadData()
        } catch {
        }
    }

    func onEntryAdded() {
        addEntryViewModel = nil
        Task {
            await loadData()
        }
    }

    func showSettings() {
        settingsViewModel = SettingsViewModel(service: settingsService, notificationService: notificationService)
    }

    func showHistory() {
        historyViewModel = HistoryViewModel(service: service)
    }

    private func loadData() async {
        async let todayTask: Void = fetchTodayTotal()
        async let historyTask: Void = fetchSevenDayHistory()
        async let thirtyDayTask: Void = fetchThirtyDayHistory()
        async let goalTask: Void = fetchDailyGoal()
        async let streakTask: Void = fetchStreak()
        async let recentTask: Void = fetchRecentEntries()

        _ = await (todayTask, historyTask, thirtyDayTask, goalTask, streakTask, recentTask)
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

    private func fetchThirtyDayHistory() async {
        do {
            let calendar = Calendar.current
            let endDate = calendar.startOfDay(for: Date())
            let startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!

            thirtyDayTotals = try await service.fetchDailyTotals(from: startDate, to: endDate)
        } catch {
            thirtyDayTotals = [:]
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

    func scheduleMidnightRefresh() {
        midnightTimer?.invalidate()

        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
        let timeInterval = tomorrow.timeIntervalSince(now)

        midnightTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                await self?.handleMidnightTransition()
            }
        }
    }

    private func handleMidnightTransition() async {
        let calendar = Calendar.current
        let currentDay = calendar.startOfDay(for: Date())
        let lastRefreshDay = calendar.startOfDay(for: lastRefreshDate)

        guard currentDay > lastRefreshDay else { return }

        lastRefreshDate = Date()
        await loadData()
        await updateReminders()
        scheduleMidnightRefresh()
        reloadWidgets()
    }

    func handleScenePhaseChange(_ phase: ScenePhase) {
        if phase == .active {
            Task {
                await handleMidnightTransition()
            }
        }
    }

    private func updateReminders() async {
        let settings = settingsService.getReminderSettings()

        guard settings.enabled else {
            nextReminderTime = nil
            return
        }

        do {
            try await notificationService.scheduleReminders(settings: settings)
            nextReminderTime = await notificationService.getNextScheduledReminder()
        } catch {
            nextReminderTime = nil
        }
    }

    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
