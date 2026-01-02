import SwiftUI

struct ContentView: View {
    @State var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            if viewModel.isGoalSet, let mainViewModel = viewModel.mainViewModel {
                NavigationStack {
                    MainView(viewModel: mainViewModel)
                }
                .transition(.move(edge: .top))
            } else if let goalViewModel = viewModel.goalViewModel {
                NavigationStack {
                    GoalView(viewModel: goalViewModel)
                }
                .transition(.opacity)
            }
        }
        .animation(.default, value: viewModel.isGoalSet)
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
