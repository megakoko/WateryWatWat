import SwiftUI
import Confetti3D

struct ContentView: View {
    @State var viewModel: ContentViewModel

    private let confettiView = C3DView()

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
        .overlay {
            ZStack {
                if viewModel.showCongratulations {
                    congratulationsView
                }

                confettiView
                    .ignoresSafeArea()
            }
        }
        .onReceive(viewModel.confettiPublisher) {
            confettiView.throwConfetti()
        }
    }

    private var congratulationsView: some View {
        Color.clear
            .background(.ultraThinMaterial, in: Rectangle())
            .ignoresSafeArea()
            .overlay {
                VStack {
                    Text("congratulations.title".localized)
                        .font(.title.bold())

                    Text("congratulations.message".localized)
                        .foregroundStyle(.gray)
                }
                .offset(y: 50)
            }
            .onTapGesture(perform: viewModel.hideCongratulations)
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
