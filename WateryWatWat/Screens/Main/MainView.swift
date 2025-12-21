import SwiftUI

struct MainView: View {
    @State var viewModel: MainViewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    circularProgressCard
                    todayVolumeCard
                    streakCard
                    nextReminderPanel
                    historyPanel
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
            .sheet(item: $viewModel.addEntryViewModel) { addEntryViewModel in
                NavigationStack {
                    AddEntryView(viewModel: addEntryViewModel)
                }
            }
            .sheet(item: $viewModel.settingsViewModel) { settingsViewModel in
                NavigationStack {
                    SettingsView(viewModel: settingsViewModel)
                }
            }
            .navigationDestination(item: $viewModel.historyViewModel) { historyViewModel in
                HistoryView(viewModel: historyViewModel)
            }
            .task {
                await viewModel.onAppear()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            viewModel.handleScenePhaseChange(newPhase)
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

    private var historyPanel: some View {
        CardPanel("History", usePadding: false) {
            historyScrollView
        } trailingButton: {
            Button("See All", action: viewModel.showHistory)
                .font(.subheadline)
        }
    }

    private var historyScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.recentEntries) { group in
                        HStack(alignment: .bottom, spacing: 20) {
                            ForEach(group.entries, id: \.objectID) { entry in
                                EntryCard(entry: entry)
                            }
                            DayCard(date: group.date, totalVolume: group.totalVolume)
                        }
                        .id(group.id)
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: viewModel.recentEntries) { _, newEntries in
                if let lastGroup = newEntries.last {
                    proxy.scrollTo(lastGroup.id, anchor: .leading)
                }
            }
        }
    }

    private var sevenDayChartCard: some View {
        CardPanel("7-Day History") {
            SevenDayChartView(dailyTotals: viewModel.dailyTotals, dailyGoal: viewModel.dailyGoal)
        }
    }

    private var nextReminderPanel: some View {
        NextReminderPanel(
            nextReminderTime: viewModel.nextReminderTime,
            onAddReminder: viewModel.showSettings
        )
    }
}

#Preview {
    MainView(
        viewModel: MainViewModel(
            service: MockHydrationService(),
            settingsService: MockSettingsService(),
            notificationService: MockNotificationService()
        )
    )
}
