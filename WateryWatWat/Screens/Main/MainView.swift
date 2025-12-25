import SwiftUI

struct MainView: View {
    @State var viewModel: MainViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.sizeCategory) private var sizeCategory

    var body: some View {
        ScrollView {
            if viewModel.initialized {
                content
            }
        }
        .scrollIndicators(.hidden)
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
            .sheet(item: $viewModel.entryViewModel) { addEntryViewModel in
                NavigationStack {
                    EntryView(viewModel: addEntryViewModel)
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
            .errorAlert($viewModel.error)
            .confirmationDialog(
                "Delete Entry",
                isPresented: $viewModel.showDeleteConfirmation,
                presenting: viewModel.entryToDelete
            ) { _ in
                Button("Delete", role: .destructive, action: viewModel.confirmDelete)
            } message: { _ in
                Text("Delete entry?")
            }
            .onChange(of: scenePhase) { _, newPhase in
                viewModel.handleScenePhaseChange(newPhase)
            }
    }

    private var content: some View {
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

    private var circularProgressCard: some View {
        CardPanel {
            CircularProgressView(
                progress: viewModel.progress,
                formattedValue: viewModel.formattedTodayValue,
                symbol: viewModel.volumeSymbol,
                font: .system(size: 60, weight: .bold),
                lineWidth: 25
            )
            .contentTransition(.numericText())
            .padding(20)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var todayVolumeCard: some View {
        SimpleValueCard(title: "Goal", value: viewModel.formattedDailyGoal.uppercased())
    }

    private var streakCard: some View {
        SimpleValueCard(title: "Streak", value: viewModel.streakText)
            .contentTransition(.numericText())
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
                                EntryCard(
                                    entry: entry,
                                    onEdit: { viewModel.editEntry(entry) },
                                    onDelete: { viewModel.deleteEntry(entry) }
                                )
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
            HistoryChartView(
                dailyTotals: viewModel.statsPeriodDays == 7 ? viewModel.weekTotals : viewModel.monthTotals,
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
        SimpleValueCard(title: "Remaining", value: viewModel.formattedRemainingToGoal.uppercased())
            .contentTransition(.numericText())
    }

    private var averageIntakeCard: some View {
        SimpleValueCard(
            title: "Average",
            value: viewModel.formattedAverageIntake.uppercased(),
            periodDays: viewModel.statsPeriodDays,
            onTogglePeriod: viewModel.toggleStatsPeriod
        )
        .contentTransition(.numericText())
    }

    private var goalHitRateCard: some View {
        SimpleValueCard(
            title: "Goal Hit",
            value: "\(viewModel.goalHitRate)%",
            periodDays: viewModel.statsPeriodDays,
            onTogglePeriod: viewModel.toggleStatsPeriod
        )
        .contentTransition(.numericText())
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
    NavigationStack {
        MainView(
            viewModel: MainViewModel(
                service: MockHydrationService(),
                settingsService: MockSettingsService(),
                notificationService: MockNotificationService()
            )
        )
    }
}
