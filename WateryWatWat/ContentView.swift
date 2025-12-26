import SwiftUI

struct ContentView: View {
    @State var viewModel: ContentViewModel

    var body: some View {
        NavigationStack {
            if viewModel.isGoalSet {
                MainView(viewModel: viewModel.mainViewModel)
                    .transition(.opacity)
            } else {
                GoalView(viewModel: viewModel.goalViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isGoalSet)
    }
}

#Preview {
    ContentView(
        viewModel: ContentViewModel(
            settingsService: MockSettingsService(),
            persistenceController: PersistenceController.preview,
            healthKitService: MockHealthKitService(delay: 0, fail: false)
        )
    )
}
