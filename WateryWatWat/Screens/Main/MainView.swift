import SwiftUI

struct MainView: View {
    @State var viewModel: MainViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    circularProgressCard
                    todayVolumeCard
                    streakCard
                    sevenDayChartCard
                }
                .padding()
            }
            .navigationTitle("Hydration")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: viewModel.showSettings) {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", action: viewModel.showAddEntry)
                }
            }
            .navigationDestination(item: $viewModel.addEntryViewModel) { addEntryViewModel in
                AddEntryView(viewModel: addEntryViewModel)
            }
            .navigationDestination(item: $viewModel.settingsViewModel) { settingsViewModel in
                SettingsView(viewModel: settingsViewModel)
            }
            .task {
                await viewModel.onAppear()
            }
        }
    }

    private var circularProgressCard: some View {
        CardPanel {
            CircularProgressView(
                progress: viewModel.progress,
                current: viewModel.todayTotal,
                goal: viewModel.dailyGoal
            )
            .padding(20)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var todayVolumeCard: some View {
        CardPanel("Today's Volume") {
            Text("\(viewModel.todayTotal.formattedLiters()) L / \(viewModel.dailyGoal.formattedLiters()) L")
                .font(.largeTitle)
        }
    }

    private var streakCard: some View {
        CardPanel("Streak") {
            Text("\(viewModel.streak) days")
                .font(.largeTitle)
        }
    }

    private var sevenDayChartCard: some View {
        CardPanel("7-Day History") {
            SevenDayChartView(dailyTotals: viewModel.dailyTotals, dailyGoal: viewModel.dailyGoal)
        }
    }
}

#Preview {
    MainView(viewModel: MainViewModel(service: MockHydrationService(), settingsService: MockSettingsService()))
}
