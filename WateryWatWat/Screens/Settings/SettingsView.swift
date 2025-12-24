import SwiftUI

struct SettingsView: View {
    @State var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            dailyGoalSection
            reminderSection
        }
        .navigationTitle("Settings")
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
    }

    private var dailyGoalSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Daily Goal")
                    Spacer()
                    Text(viewModel.formattedDailyGoal)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .textCase(.uppercase)
                }
                Slider(
                    value: Binding(
                        get: { Double(viewModel.dailyGoal) },
                        set: { viewModel.dailyGoal = Int64($0) }
                    ),
                    in: Double(Constants.minGoalML)...Double(Constants.maxGoalML),
                    step: Double(Constants.stepGoalML)
                ) {
                    Text("Daily Goal")
                } minimumValueLabel: {
                    Text(viewModel.formattedMinGoal)
                        .font(.caption)
                        .monospacedDigit()
                        .textCase(.uppercase)
                } maximumValueLabel: {
                    Text(viewModel.formattedMaxGoal)
                        .font(.caption)
                        .monospacedDigit()
                        .textCase(.uppercase)
                }
            }
        }
    }

    private var reminderSection: some View {
        Section {
            Toggle("Enable Reminders", isOn: $viewModel.remindersEnabled)
                .disabled(viewModel.shouldShowPermissionDenied)

            if viewModel.remindersEnabled {
                DatePicker(
                    "Start Time",
                    selection: $viewModel.reminderStartTime,
                    displayedComponents: [.hourAndMinute]
                )

                DatePicker(
                    "End Time",
                    selection: $viewModel.reminderEndTime,
                    displayedComponents: [.hourAndMinute]
                )

                Picker("Remind Every", selection: $viewModel.reminderPeriodMinutes) {
                    ForEach(viewModel.availablePeriods, id: \.self) { minutes in
                        Text(viewModel.formatPeriod(minutes)).tag(minutes)
                    }
                }
            }

            if viewModel.shouldShowPermissionDenied {
                Text("Notifications are disabled. Please enable them in Settings.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("Open Settings", action: viewModel.openAppSettings)
            }
        } header: {
            Text("Drink Reminders")
        } footer: {
            if viewModel.shouldShowNotificationSettings {
                Button("Notification Settings", action: viewModel.openAppSettings)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            viewModel: SettingsViewModel(
                service: MockSettingsService(),
                notificationService: MockNotificationService()
            )
        )
    }
}
