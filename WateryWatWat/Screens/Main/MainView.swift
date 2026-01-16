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
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("app.title".localized)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: viewModel.showSettings) {
                    Image(systemName: "gearshape")
                }
            }

            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
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
                formattedValue: viewModel.formattedTodayComponents.value,
                symbol: viewModel.formattedTodayComponents.unit,
                unitPosition: viewModel.formattedTodayComponents.unitPosition,
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
        SimpleValueCard(title: "card.goal".localized, value: viewModel.formattedDailyGoal.uppercased())
    }

    private var streakCard: some View {
        SimpleValueCard(title: "card.streak".localized, value: viewModel.streakText)
            .contentTransition(.numericText())
    }

    private var historyPanel: some View {
        CardPanel("card.history".localized, usePadding: false) {
            historyScrollView
        } trailingButton: {
            Button("button.seeAll".localized, action: viewModel.showHistory)
        }
    }

    private var historyScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.recentEntries) { group in
                    HStack(alignment: .bottom, spacing: 0) {
                        DayCard(date: group.date, formattedVolume: group.formattedTotalVolume)

                        ForEach(group.entries, id: \.objectID) { entry in
                            Button {
                                viewModel.editEntry(entry)
                            } label: {
                                EntryCard(entry: entry)
                            }
                            .padding(.horizontal, 10)
                            .contentShape(Rectangle())
                            .contextMenu {
                                Button("button.duplicate".localized, systemImage: "plus.square.on.square") {
                                    viewModel.duplicateEntry(entry)
                                }
                                Button("button.delete".localized, systemImage: "trash", role: .destructive) {
                                    viewModel.deleteEntry(entry)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .confirmationDialog(
            "confirmation.deleteEntry.title".localized,
            isPresented: $viewModel.showDeleteConfirmation,
            presenting: viewModel.entryToDelete
        ) { _ in
            Button("button.delete".localized, role: .destructive, action: viewModel.confirmDelete)
        } message: { entry in
            Text("confirmation.deleteEntry.message".localized(viewModel.formattedVolumeToDelete))
        }
    }

    private var sevenDayChartCard: some View {
        CardPanel("card.dayHistory".localized(viewModel.statsPeriod.days)) {
            HistoryChartView(
                dailyTotals: viewModel.statsPeriod == .week ? viewModel.weekTotals : viewModel.monthTotals,
                goalPeriods: viewModel.goalPeriods,
                periodDays: viewModel.statsPeriod.days,
                onTogglePeriod: viewModel.toggleStatsPeriod
            )
        } trailingButton: {
            Button(action: viewModel.toggleStatsPeriod) {
                Text("period.days".localized(viewModel.statsPeriod.days))
                    .animation(nil, value: viewModel.statsPeriod)
            }
        }
    }

    private var nextReminderPanel: some View {
        CardPanel("card.nextDrink".localized) {
            NextReminderPanel(
                nextReminderTime: viewModel.nextReminderTime,
                onAddReminder: viewModel.showSettings
            )
        }
    }

    private var remainingToGoalCard: some View {
        SimpleValueCard(title: "card.remaining".localized, value: viewModel.formattedRemainingToGoal.uppercased())
            .contentTransition(.numericText())
    }

    private var averageIntakeCard: some View {
        SimpleValueCard(
            title: "card.average".localized,
            value: viewModel.formattedAverageIntake.uppercased(),
            periodDays: viewModel.statsPeriod.days,
            onTogglePeriod: viewModel.toggleStatsPeriod
        )
        .contentTransition(.numericText())
    }

    private var goalHitRateCard: some View {
        SimpleValueCard(
            title: "card.goalHit".localized,
            value: "\(viewModel.goalHitRate)%",
            periodDays: viewModel.statsPeriod.days,
            onTogglePeriod: viewModel.toggleStatsPeriod
        )
        .contentTransition(.numericText())
    }

    private var addButton: some View {
        Menu {
            ForEach(Constants.standardVolumes, id: \.self) { volume in
                Button(viewModel.formattedVolume(for: volume)) {
                    viewModel.quickAddEntry(volume: volume)
                }
            }
        } label: {
            Label("button.add".localized, systemImage: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal)
                .padding()
                .glassEffect(.clear.tint(.accent).interactive())
                .padding()
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
