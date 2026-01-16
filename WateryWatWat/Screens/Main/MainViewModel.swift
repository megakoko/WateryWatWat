import Foundation
import CoreData
import Combine
import SwiftUI
import WidgetKit

@Observable
final class MainViewModel {
    var todayTotal: Int64 = 0
    var weekTotals: [DailyTotal] = []
    var monthTotals: [DailyTotal] = []
    var dailyGoal: Int64 = Constants.defaultDailyGoalML
    var streak: Int = 0
    var recentEntries: [GroupedHydrationEntries] = []
    var entryViewModel: EntryViewModel?
    var settingsViewModel: SettingsViewModel?
    var historyViewModel: HistoryViewModel?
    var nextReminderTime: Date?
    var statsPeriod: StatsPeriod = .week
    var entryToDelete: HydrationEntry?
    var showDeleteConfirmation = false
    var error: Error?
    var initialized = false

    var formattedVolumeToDelete: String {
        guard let entry = entryToDelete else { return "" }
        let mlFormatter = VolumeFormatter(unit: .milliliters)
        return mlFormatter.string(from: entry.volume)
    }

    var progress: Double {
        Double(todayTotal) / Double(dailyGoal)
    }

    var remainingToGoal: Int64 {
        max(0, dailyGoal - todayTotal)
    }

    var formattedRemainingToGoal: String {
        volumeFormatter.string(from: remainingToGoal)
    }

    var formattedDailyGoal: String {
        volumeFormatter.string(from: dailyGoal)
    }

    var goalPeriods: [GoalPeriod] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let daysBack = statsPeriod == .week ? 6 : 29
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: today)!
        return [GoalPeriod(start: startDate, end: today, value: dailyGoal)]
    }

    var formattedAverageIntake: String {
        volumeFormatter.string(from: averageIntake)
    }

    var formattedTodayTotal: String {
        volumeFormatter.string(from: todayTotal)
    }

    var formattedTodayComponents: FormattedVolume {
        volumeFormatter.formattedComponents(from: todayTotal)
    }

    private var averageCalculationDays: [DailyTotal] {
        let totals = statsPeriod == .week ? weekTotals : monthTotals
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let datesWithData = totals.drop(while: { $0.volume == 0 })

        return datesWithData.filter { dailyTotal in
            !calendar.isDate(dailyTotal.date, inSameDayAs: today) || dailyTotal.volume >= dailyGoal
        }
    }

    var averageIntake: Int64 {
        let days = averageCalculationDays

        guard !days.isEmpty else {
            return 0
        }

        let total = days.reduce(Int64(0)) { $0 + $1.volume }
        return total / Int64(days.count)
    }

    var goalHitRate: Int {
        let days = averageCalculationDays

        guard !days.isEmpty else {
            return 0
        }

        let daysMetGoal = days.count(where: { $0.volume >= dailyGoal })

        return Int((Double(daysMetGoal) / Double(days.count)) * 100)
    }

    func toggleStatsPeriod() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        statsPeriod = statsPeriod.toggled()
        settingsService.setStatsPeriod(statsPeriod)
    }

    var streakText: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day]

        let components = DateComponents(day: streak)
        return formatter.string(from: components)!
    }

    private let service: HydrationService
    private let settingsService: SettingsService
    private let notificationService: NotificationService
    private let healthKitService: HealthKitService
    private let notificationDelegate = NotificationDelegate()
    private let volumeFormatter = VolumeFormatter(unit: .liters)
    private var cancellables = Set<AnyCancellable>()
    private var midnightTimer: Timer?
    private var lastRefreshDate: Date = Date()

    init(service: HydrationService, settingsService: SettingsService, notificationService: NotificationService, healthKitService: HealthKitService) {
        self.service = service
        self.settingsService = settingsService
        self.notificationService = notificationService
        self.healthKitService = healthKitService

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSPersistentStoreRemoteChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.loadData(initialLoad: false)
                self?.reloadWidgets()
            }
        }

        UserDefaults.standard.publisher(for: \.dailyGoalML)
            .sink { [weak self] _ in
                Task {
                    do {
                        let dailyGoal = try await self?.fetchDailyGoal()
                        let streak = try await self?.fetchStreak()
                        if let dailyGoal, let streak {
                            self?.dailyGoal = dailyGoal
                            self?.streak = streak
                        }
                    } catch {
                        self?.error = error
                    }
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
        statsPeriod = settingsService.getStatsPeriod()
        await loadData(initialLoad: true)
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
        entryViewModel = EntryViewModel(service: service)
    }

    func quickAddEntry(volume: Int64) {
        Task {
            await addQuickEntry(volume: volume)
        }
    }

    private func addQuickEntry(volume: Int64) async {
        do {
            try await service.addEntry(volume: volume, type: .water, date: Date())
            await loadData(initialLoad: false)
        } catch {
            self.error = error
        }
    }

    func onEntryAdded() {
        entryViewModel = nil
        Task {
            await loadData(initialLoad: false)
        }
    }

    func showSettings() {
        settingsViewModel = SettingsViewModel(service: settingsService, notificationService: notificationService, healthKitService: healthKitService)
    }

    func showHistory() {
        historyViewModel = HistoryViewModel(service: service)
    }

    func editEntry(_ entry: HydrationEntry) {
        entryViewModel = EntryViewModel(service: service, entry: entry)
    }

    func deleteEntry(_ entry: HydrationEntry) {
        entryToDelete = entry
        showDeleteConfirmation = true
    }

    func confirmDelete() {
        guard let entry = entryToDelete else { return }
        Task {
            await performDelete(entry: entry)
        }
        entryToDelete = nil
    }

    func duplicateEntry(_ entry: HydrationEntry) {
        Task {
            await performDuplicate(entry: entry)
        }
    }
    
    func formattedVolume(for volume: Int64) -> String {
        let mlFormatter = VolumeFormatter(unit: .milliliters)
        return mlFormatter.string(from: volume)
    }

    private func performDelete(entry: HydrationEntry) async {
        do {
            try await service.deleteEntry(entry)
            await loadData(initialLoad: false)
        } catch {
            self.error = error
        }
    }

    private func performDuplicate(entry: HydrationEntry) async {
        do {
            try await service.duplicateEntry(entry)
            await loadData(initialLoad: false)
        } catch {
            self.error = error
        }
    }

    private func loadData(initialLoad: Bool) async {
        do {
            async let todayTask = fetchTodayTotal()
            async let historyTask = fetchHistory()
            async let goalTask = fetchDailyGoal()
            async let streakTask = fetchStreak()
            async let recentTask = fetchRecentEntries()

            let (todayTotal, (monthTotals, weekTotals), dailyGoal, streak, recentEntries) = try await (todayTask, historyTask, goalTask, streakTask, recentTask)

            let animation = initialLoad ? nil : Animation.default
            withAnimation(animation) {
                self.todayTotal = todayTotal
                self.monthTotals = monthTotals
                self.weekTotals = weekTotals
                self.dailyGoal = dailyGoal
                self.streak = streak
                self.recentEntries = recentEntries
                self.initialized = true
            }
        } catch {
            self.error = error
        }
    }

    private func fetchDailyGoal() async throws -> Int64 {
        settingsService.getDailyGoal()
    }

    private func fetchTodayTotal() async throws -> Int64 {
        try await service.fetchTodayTotal()
    }

    private func fetchHistory() async throws -> ([DailyTotal], [DailyTotal]) {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!

        let monthTotals = try await service.fetchDailyTotals(from: startDate, to: endDate)
        let weekTotals = Array(monthTotals.suffix(7))
        return (monthTotals, weekTotals)
    }

    private func fetchStreak() async throws -> Int {
        try await service.calculateStreak(goal: dailyGoal)
    }

    private func fetchRecentEntries() async throws -> [GroupedHydrationEntries] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!

        let entries = try await service.fetchEntries(from: startDate, to: endDate)

        var grouped: [Date: [HydrationEntry]] = [:]
        for entry in entries {
            let dayStart = calendar.startOfDay(for: entry.date!)
            grouped[dayStart, default: []].append(entry)
        }

        return grouped.map { date, entries in
            GroupedHydrationEntries(date: date, entries: entries)
        }.sorted { $0.date > $1.date }
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
        await loadData(initialLoad: false)
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
