import SwiftUI
import Confetti3D

struct MainView: View {
    @State var viewModel: MainViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.sizeCategory) private var sizeCategory

    private let confettiView = C3DView()
    private let extraAddButtonSpacing = 100.0
    
    var body: some View {
        ScrollView {
            if viewModel.initialized {
                content
                    .padding(.bottom, extraAddButtonSpacing)
            }
        }
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("app.title".localized)
        .toolbar {
            if !viewModel.showCongratulations {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: viewModel.showSettings) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if viewModel.initialized {
                addButton
                    .ignoresSafeArea()
            }
        }
        .overlay {
            ZStack {
                if viewModel.showCongratulations {
                    congratulationsView
                }
                
                confettiView
                    .ignoresSafeArea()
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
                    HStack(alignment: .bottom, spacing: 20) {
                        DayCard(date: group.date, formattedVolume: group.formattedTotalVolume)

                        ForEach(group.entries, id: \.objectID) { entry in
                            Menu {
                                Button("button.delete".localized, systemImage: "trash", role: .destructive) {
                                    viewModel.deleteEntry(entry)
                                }
                            } label: {
                                EntryCard(entry: entry)
                            } primaryAction: {
                                viewModel.editEntry(entry)
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
                dailyGoal: viewModel.dailyGoal,
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
                Button("volume.ml".localized(volume)) {
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
