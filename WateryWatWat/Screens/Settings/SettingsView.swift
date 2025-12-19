import SwiftUI

struct SettingsView: View {
    @State var viewModel: SettingsViewModel

    var body: some View {
        Form {
            dailyGoalSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
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
        .onChange(of: viewModel.dailyGoal) { _, _ in
            Task {
                await viewModel.saveDailyGoal()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel(service: MockSettingsService()))
    }
}
