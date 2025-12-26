import SwiftUI

struct ContentView: View {
    @State var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            if viewModel.isGoalSet {
                NavigationStack {
                    MainView(viewModel: viewModel.mainViewModel)
                }
                .transition(.move(edge: .top))
            } else {
                NavigationStack {
                    GoalView(viewModel: viewModel.goalViewModel)
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
