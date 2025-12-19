import SwiftUI

struct MainView: View {
    @State var viewModel: MainViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    circularProgressCard
                    todayVolumeCard
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
        CircularProgressView(
            progress: viewModel.progress,
            current: viewModel.todayTotal,
            goal: viewModel.dailyGoal
        )
        .padding(40)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .aspectRatio(1, contentMode: .fit)
    }

    private var todayVolumeCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Volume")
                .font(.headline)
            Text("\(viewModel.todayTotal.formattedLiters()) L / \(viewModel.dailyGoal.formattedLiters()) L")
                .font(.largeTitle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var sevenDayChartCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("7-Day History")
                .font(.headline)
            SevenDayChartView(dailyTotals: viewModel.dailyTotals, dailyGoal: viewModel.dailyGoal)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MainView(viewModel: MainViewModel(service: MockHydrationService(), settingsService: MockSettingsService()))
}
