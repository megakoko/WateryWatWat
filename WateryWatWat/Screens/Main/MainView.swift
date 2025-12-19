import SwiftUI

struct MainView: View {
    @State var viewModel: MainViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    todayVolumeCard
                    sevenDayChartCard
                }
                .padding()
            }
            .navigationTitle("Hydration")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", action: viewModel.showAddEntry)
                }
            }
            .navigationDestination(item: $viewModel.addEntryViewModel) { addEntryViewModel in
                AddEntryView(viewModel: addEntryViewModel)
            }
            .task {
                await viewModel.onAppear()
            }
        }
    }

    private var todayVolumeCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Volume")
                .font(.headline)
            Text("\(viewModel.todayTotal) ml")
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
            SevenDayChartView(dailyTotals: viewModel.dailyTotals)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MainView(viewModel: MainViewModel(service: MockHydrationService()))
}
