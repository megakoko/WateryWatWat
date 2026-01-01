import SwiftUI

struct SettingsView: View {
    @State var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            dailyGoalSection
            reminderSection
            healthSection
        }
        .navigationTitle("navigation.settings".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .task {
            await viewModel.onAppear()
        }
        .errorAlert($viewModel.error)
        .alert("alert.deleteHealthData.title".localized, isPresented: $viewModel.showDeleteConfirmation) {
            Button("button.cancel".localized, role: .cancel) { }
            Button("button.delete".localized, role: .destructive) {
                Task {
                    await viewModel.confirmDeleteHealthData()
                }
            }
        } message: {
            Text("alert.deleteHealthData.message".localized)
        }
        .alert("alert.result".localized, isPresented: $viewModel.showDeleteResult) {
            Button("OK", role: .cancel) { }
        } message: {
            if let message = viewModel.deleteResultMessage {
                Text(message)
            }
        }
    }

    private var dailyGoalSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("settings.section.dailyGoal".localized)
                    Spacer()
                    Text(viewModel.formattedDailyGoal)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .textCase(.uppercase)
                }
                GoalSlider(
                    goal: $viewModel.dailyGoal,
                    minGoal: Constants.minGoalML,
                    maxGoal: Constants.maxGoalML,
                    step: Constants.stepGoalML
                )
            }
        }
    }

    private var reminderSection: some View {
        Section {
            Toggle("form.enableReminders".localized, isOn: $viewModel.remindersEnabled)
                .disabled(viewModel.shouldShowPermissionDenied)

            if viewModel.remindersEnabled {
                DatePicker(
                    "form.startTime".localized,
                    selection: $viewModel.reminderStartTime,
                    displayedComponents: [.hourAndMinute]
                )

                DatePicker(
                    "form.endTime".localized,
                    selection: $viewModel.reminderEndTime,
                    displayedComponents: [.hourAndMinute]
                )

                Picker("form.remindEvery".localized, selection: $viewModel.reminderPeriodMinutes) {
                    ForEach(viewModel.availablePeriods, id: \.self) { minutes in
                        Text(viewModel.formatPeriod(minutes)).tag(minutes)
                    }
                }
            }

            if viewModel.shouldShowPermissionDenied {
                Text("alert.notificationsDisabled".localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("button.openSettings".localized, action: viewModel.openAppSettings)
            }
        } header: {
            Text("settings.section.reminders".localized)
        } footer: {
            if viewModel.shouldShowNotificationSettings {
                Button("button.notificationSettings".localized, action: viewModel.openAppSettings)
            }
        }
    }

    private var healthSection: some View {
        Section {
            Toggle("form.syncToHealth".localized, isOn: $viewModel.healthSyncEnabled)

            if viewModel.healthSyncEnabled {
                Button("button.deleteHealthData".localized, role: .destructive, action: viewModel.deleteHealthData)
            }
        } header: {
            Text("settings.section.health".localized)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            viewModel: SettingsViewModel(
                service: MockSettingsService(),
                notificationService: MockNotificationService(),
                healthKitService: MockHealthKitService(delay: 0, fail: false)
            )
        )
    }
}
