import SwiftUI
import Confetti3D

struct MainView: View {
    @State var viewModel: MainViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.sizeCategory) private var sizeCategory
    
    private let confettiView = C3DView()
    
    var body: some View {
        ScrollView {
            if viewModel.initialized {
                content
            }
        }
        .overlay {
            confettiView
                .ignoresSafeArea()
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Hydration")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: viewModel.showSettings) {
                    Image(systemName: "gearshape")
                }
            }
            
            if #available(iOS 26, *) {
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    addButton
                }
            } else {
                ToolbarItem(placement: .primaryAction) {
                    addButton
                }
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
        .onChange(of: scenePhase) { _, newPhase in
            viewModel.handleScenePhaseChange(newPhase)
        }
        .onReceive(viewModel.confettiPublisher) {
            confettiView.throwConfetti()
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
                lineWidth: 25,
                color: .accentColor
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.recentEntries) { group in
                    HStack(alignment: .bottom, spacing: 20) {
                        DayCard(date: group.date, formattedVolume: group.formattedTotalVolume)

                        ForEach(group.entries, id: \.objectID) { entry in
                            EntryCard(
                                entry: entry,
                                onEdit: { viewModel.editEntry(entry) },
                                onDelete: { viewModel.deleteEntry(entry) }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .confirmationDialog(
            "Delete Entry",
            isPresented: $viewModel.showDeleteConfirmation,
            presenting: viewModel.entryToDelete
        ) { _ in
            Button("Delete", role: .destructive, action: viewModel.confirmDelete)
        } message: { _ in
            Text("Delete entry?")
        }
    }

    private var sevenDayChartCard: some View {
        CardPanel("\(viewModel.statsPeriod.days)-Day History") {
            HistoryChartView(
                dailyTotals: viewModel.statsPeriod == .week ? viewModel.weekTotals : viewModel.monthTotals,
                dailyGoal: viewModel.dailyGoal,
                periodDays: viewModel.statsPeriod.days,
                onTogglePeriod: viewModel.toggleStatsPeriod
            )
        } trailingButton: {
            Button(action: viewModel.toggleStatsPeriod) {
                Text("\(viewModel.statsPeriod.days)d")
                    .animation(nil, value: viewModel.statsPeriod)
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
            periodDays: viewModel.statsPeriod.days,
            onTogglePeriod: viewModel.toggleStatsPeriod
        )
        .contentTransition(.numericText())
    }

    private var goalHitRateCard: some View {
        SimpleValueCard(
            title: "Goal Hit",
            value: "\(viewModel.goalHitRate)%",
            periodDays: viewModel.statsPeriod.days,
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
                notificationService: MockNotificationService(),
                healthKitService: MockHealthKitService(delay: 0, fail: false)
            )
        )
    }
}
