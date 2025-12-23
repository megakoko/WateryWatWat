import SwiftUI

struct MainView: View {
    @State var viewModel: MainViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.sizeCategory) private var sizeCategory

    var body: some View {
        NavigationStack {
            ScrollView {
                Grid {
                    WateryRow {
                        circularProgressCard
                    }

                    WateryRow {
                        remainingToGoalCard
                    } trailing: {
                        todayVolumeCard
                    }

                    WateryRow {
                        streakCard
                    } trailing: {
                        nextReminderPanel
                    }

                    WateryRow {
                        averageIntakeCard
                    } trailing: {
                        goalHitRateCard
                    }

                    WateryRow {
                        sevenDayChartCard
                    }

                    WateryRow {
                        historyPanel
                    }
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
                    addButton
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
                formattedValue: viewModel.formattedTodayValue,
                symbol: viewModel.volumeSymbol,
                font: .system(size: 60, weight: .bold),
                lineWidth: 25
            )
            .padding(20)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var todayVolumeCard: some View {
        SimpleValueCard(title: "Goal", value: viewModel.formattedDailyGoal)
    }

    private var streakCard: some View {
        SimpleValueCard(title: "Streak", value: viewModel.streakText)
    }

    private var historyPanel: some View {
        CardPanel("History", usePadding: false) {
            historyScrollView
        } trailingButton: {
            Button("See All", action: viewModel.showHistory)
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
                            DayCard(date: group.date, formattedVolume: group.formattedTotalVolume)
                        }
                    }
                }
                .padding(.horizontal)
                .id("history-scroll-content")
            }
            .onChange(of: viewModel.recentEntries) { _, newEntries in
                proxy.scrollTo("history-scroll-content", anchor: .trailing)
            }
        }
    }

    private var sevenDayChartCard: some View {
        CardPanel("\(viewModel.statsPeriodDays)-Day History") {
            SevenDayChartView(
                dailyTotals: viewModel.statsPeriodDays == 7 ? viewModel.dailyTotals : viewModel.thirtyDayTotals,
                dailyGoal: viewModel.dailyGoal,
                periodDays: viewModel.statsPeriodDays,
                onTogglePeriod: viewModel.toggleStatsPeriod
            )
        } trailingButton: {
            Button(action: viewModel.toggleStatsPeriod) {
                Text("\(viewModel.statsPeriodDays)d")
                    .animation(nil, value: viewModel.statsPeriodDays)
            }
        }
    }

    private var nextReminderPanel: some View {
        CardPanel("Next Drink") {
            NextReminderPanel(
                nextReminderTime: viewModel.nextReminderTime,
                onAddReminder: viewModel.showSettings
            )
        }
    }

    private var remainingToGoalCard: some View {
        SimpleValueCard(title: "Remaining", value: viewModel.formattedRemainingToGoal)
    }

    private var averageIntakeCard: some View {
        SimpleValueCard(
            title: "Average",
            value: viewModel.formattedAverageIntake,
            periodDays: viewModel.statsPeriodDays,
            onTogglePeriod: viewModel.toggleStatsPeriod
        )
    }

    private var goalHitRateCard: some View {
        SimpleValueCard(
            title: "Goal Hit",
            value: "\(viewModel.goalHitRate)%",
            periodDays: viewModel.statsPeriodDays,
            onTogglePeriod: viewModel.toggleStatsPeriod
        )
    }

    private var addButton: some View {
        Menu("Add", systemImage: "plus") {
            ForEach(Constants.standardVolumes, id: \.self) { volume in
                Button("\(volume) ml") {
                    viewModel.quickAddEntry(volume: volume)
                }
            }
        } primaryAction: {
            viewModel.showAddEntry()
        }
    }

    private var shouldUseAccessibilityLayout: Bool {
        sizeCategory.isAccessibilityCategory
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
