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
            HStack {
                Text("Daily Goal")
                Spacer()
                Stepper(
                    value: $viewModel.dailyGoal,
                    in: 500...5000,
                    step: 50
                ) {
                    Text("\(viewModel.dailyGoal) ml")
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
