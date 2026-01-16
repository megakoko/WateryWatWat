import Foundation
import UIKit
import UserNotifications

@Observable
final class SettingsViewModel: Identifiable {
    let id = UUID()
    var dailyGoal: Int64 = Constants.defaultDailyGoalML {
        didSet {
            saveDailyGoal()
        }
    }
    var remindersEnabled = false {
        didSet {
            Task {
                await saveReminderEnabled()
            }
        }
    }
    var reminderStartTime = Date() {
        didSet {
            Task {
                await saveReminderStartTime()
            }
        }
    }
    var reminderEndTime = Date() {
        didSet {
            Task {
                await saveReminderEndTime()
            }
        }
    }
    var reminderPeriodMinutes = Constants.defaultReminderPeriodMinutes {
        didSet {
            Task {
                await saveReminderPeriod()
            }
        }
    }
    var healthSyncEnabled = false {
        didSet {
            Task {
                await toggleHealthSync()
            }
        }
    }
    var isLoading = false
    var permissionStatus: UNAuthorizationStatus = .notDetermined
    var error: Error?
    var showDeleteConfirmation = false
    var deleteResultMessage: String?
    var showDeleteResult = false

    var shouldShowPermissionDenied: Bool {
        remindersEnabled && permissionStatus == .denied
    }

    var shouldShowNotificationSettings: Bool {
        remindersEnabled && permissionStatus == .authorized
    }

    var availablePeriods: [Int] {
        Array(stride(
            from: Constants.minReminderPeriodMinutes,
            through: Constants.maxReminderPeriodMinutes,
            by: Constants.stepReminderPeriodMinutes
        ))
    }

    var formattedDailyGoal: String {
        volumeFormatter.string(from: dailyGoal)
    }

    private let settingsService: SettingsService
    private let hydrationService: HydrationService
    private let notificationService: NotificationService
    private let volumeFormatter = VolumeFormatter(unit: .liters)
    private let healthKitService: HealthKitService
    private var isInitialLoad = true

    init(settingsService: SettingsService, hydrationService: HydrationService, notificationService: NotificationService, healthKitService: HealthKitService) {
        self.settingsService = settingsService
        self.hydrationService = hydrationService
        self.notificationService = notificationService
        self.healthKitService = healthKitService
    }

    func onAppear() async {
        isInitialLoad = true

        do {
            dailyGoal = try await hydrationService.getDailyGoal()
        } catch {
            self.error = error
        }

        let settings = settingsService.getReminderSettings()
        remindersEnabled = settings.enabled
        reminderStartTime = dateFromComponents(hour: settings.startHour, minute: settings.startMinute)
        reminderEndTime = dateFromComponents(hour: settings.endHour, minute: settings.endMinute)
        reminderPeriodMinutes = settings.periodMinutes

        healthSyncEnabled = settingsService.getHealthSyncEnabled()

        await checkPermissionStatus()

        isInitialLoad = false
    }

    private func saveDailyGoal() {
        guard !isInitialLoad else { return }
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await hydrationService.setDailyGoal(dailyGoal)
            } catch {
                self.error = error
            }
        }
    }

    private func saveReminderEnabled() async {
        guard !isInitialLoad else { return }

        if remindersEnabled {
            let granted = await notificationService.requestPermission()
            await checkPermissionStatus()

            if !granted {
                remindersEnabled = false
                return
            }
        }

        isLoading = true
        defer { isLoading = false }

        settingsService.setReminderEnabled(remindersEnabled)

        let settings = settingsService.getReminderSettings()
        do {
            try await notificationService.scheduleReminders(settings: settings)
        } catch {
            self.error = error
        }
    }

    private func saveReminderStartTime() async {
        guard !isInitialLoad else { return }
        isLoading = true
        defer { isLoading = false }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderStartTime)

        settingsService.setReminderStartTime(hour: components.hour ?? 8, minute: components.minute ?? 0)
    }

    private func saveReminderEndTime() async {
        guard !isInitialLoad else { return }
        isLoading = true
        defer { isLoading = false }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderEndTime)

        settingsService.setReminderEndTime(hour: components.hour ?? 22, minute: components.minute ?? 0)
    }

    private func saveReminderPeriod() async {
        guard !isInitialLoad else { return }
        isLoading = true
        defer { isLoading = false }

        settingsService.setReminderPeriod(reminderPeriodMinutes)
    }

    private func dateFromComponents(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? Date()
    }

    func formatPeriod(_ minutes: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        return formatter.string(from: TimeInterval(minutes * 60)) ?? "\(minutes) min"
    }

    func checkPermissionStatus() async {
        permissionStatus = await notificationService.getAuthorizationStatus()
    }

    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func toggleHealthSync() async {
        guard !isInitialLoad else { return }

        if healthSyncEnabled {
            do {
                try await healthKitService.requestAuthorization()
                let authorized = await healthKitService.isAuthorized()

                if !authorized {
                    healthSyncEnabled = false
                    return
                }

                settingsService.setHealthSyncEnabled(true)
            } catch {
                healthSyncEnabled = false
            }
        } else {
            settingsService.setHealthSyncEnabled(false)
        }
    }

    func deleteHealthData() {
        showDeleteConfirmation = true
    }

    func confirmDeleteHealthData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let count = try await healthKitService.deleteAllRecords()
            deleteResultMessage = "Deleted \(count) records from Apple Health"
            showDeleteResult = true
        } catch {
            deleteResultMessage = error.localizedDescription
            showDeleteResult = true
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
