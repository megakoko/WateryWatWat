import SwiftUI

struct MainView: View {
    @State var viewModel: MainViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.sizeCategory) private var sizeCategory

    var body: some View {
        NavigationStack {
            ScrollView {
                Grid {
                    GridRow {
                        circularProgressCard
                            .gridCellColumns(2)
                    }

                    if shouldUseAccessibilityLayout {
                        GridRow {
                            todayVolumeCard
                        }
                        .gridCellColumns(2)
                        
                        GridRow {
                            streakCard
                        }
                        .gridCellColumns(2)
                        
                        GridRow {
                            nextReminderPanel
                                .gridCellColumns(2)
                        }
                        
                        GridRow {
                            sevenDayChartCard
                                .gridCellColumns(2)
                        }
                    } else {
                        GridRow {
                            todayVolumeCard
                            streakCard
                        }
                        GridRow {
                            nextReminderPanel
                            sevenDayChartCard
                        }
                    }
                    GridRow {
                        historyPanel
                            .gridCellColumns(2)
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
                current: viewModel.todayTotal,
                goal: viewModel.dailyGoal,
                font: .system(size: 60, weight: .bold),
                lineWidth: 25
            )
            .padding(20)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var todayVolumeCard: some View {
        CardPanel("Today") {
            Text("\(viewModel.todayTotal.formattedLiters()) L / \(viewModel.dailyGoal.formattedLiters()) L")
                .lineLimit(1)
                .font(.largeTitle)
        }
    }

    private var streakCard: some View {
        CardPanel("Streak") {
            Text(viewModel.streakText)
                .lineLimit(1)
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
        CardPanel("7-Day History") {
            SevenDayChartView(dailyTotals: viewModel.dailyTotals, dailyGoal: viewModel.dailyGoal)
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
