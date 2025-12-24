import Foundation
import UIKit
import UserNotifications

@Observable
final class SettingsViewModel: Identifiable {
    let id = UUID()
    var dailyGoal: Int64 = Constants.defaultDailyGoalML {
        didSet {
            Task {
                await saveDailyGoal()
            }
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
    var isLoading = false
    var permissionStatus: UNAuthorizationStatus = .notDetermined
    var error: Error?

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

    var formattedMinGoal: String {
        volumeFormatter.string(from: Constants.minGoalML)
    }

    var formattedMaxGoal: String {
        volumeFormatter.string(from: Constants.maxGoalML)
    }

    private let service: SettingsServiceProtocol
    private let notificationService: NotificationService
    private let volumeFormatter = VolumeFormatter(unit: .liters)
    private var isInitialLoad = true

    init(service: SettingsServiceProtocol, notificationService: NotificationService) {
        self.service = service
        self.notificationService = notificationService
    }

    func onAppear() async {
        isInitialLoad = true

        dailyGoal = service.getDailyGoal()

        let settings = service.getReminderSettings()
        remindersEnabled = settings.enabled
        reminderStartTime = dateFromComponents(hour: settings.startHour, minute: settings.startMinute)
        reminderEndTime = dateFromComponents(hour: settings.endHour, minute: settings.endMinute)
        reminderPeriodMinutes = settings.periodMinutes

        await checkPermissionStatus()

        isInitialLoad = false
    }

    private func saveDailyGoal() async {
        guard !isInitialLoad else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.setDailyGoal(dailyGoal)
        } catch {
            self.error = error
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

        do {
            try await service.setReminderEnabled(remindersEnabled)

            let settings = service.getReminderSettings()
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

        do {
            try await service.setReminderStartTime(hour: components.hour ?? 8, minute: components.minute ?? 0)
        } catch {
            self.error = error
        }
    }

    private func saveReminderEndTime() async {
        guard !isInitialLoad else { return }
        isLoading = true
        defer { isLoading = false }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderEndTime)

        do {
            try await service.setReminderEndTime(hour: components.hour ?? 22, minute: components.minute ?? 0)
        } catch {
            self.error = error
        }
    }

    private func saveReminderPeriod() async {
        guard !isInitialLoad else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.setReminderPeriod(reminderPeriodMinutes)
        } catch {
            self.error = error
        }
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
}

extension SettingsViewModel: Hashable {
    static func == (lhs: SettingsViewModel, rhs: SettingsViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
