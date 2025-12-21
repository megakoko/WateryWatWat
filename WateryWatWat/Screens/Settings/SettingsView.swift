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
                Button("Close") {
                    dismiss()
                }
            }
        }
        .task {
            await viewModel.onAppear()
        }
    }

    private var dailyGoalSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Daily Goal")
                    Spacer()
                    Text("\(viewModel.dailyGoal.formattedLiters()) L")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
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
                    Text("\(Constants.minGoalML.formattedLiters()) L")
                        .font(.caption)
                        .monospacedDigit()
                } maximumValueLabel: {
                    Text("\(Constants.maxGoalML.formattedLiters()) L")
                        .font(.caption)
                        .monospacedDigit()
                }
            }
        }
    }

    private var reminderSection: some View {
        Section {
            Toggle("Enable Reminders", isOn: $viewModel.remindersEnabled)

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

            if viewModel.shouldShowNotificationSettings {
                Button("Notification Settings", action: viewModel.openAppSettings)
            }
        } header: {
            Text("Drink Reminders")
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
