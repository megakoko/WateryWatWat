import Foundation

@Observable
final class MainViewModel {
    var todayTotal: Int64 = 0
    var dailyTotals: [Date: Int64] = [:]
    var addEntryViewModel: AddEntryViewModel?

    private let service: HydrationServiceProtocol

    init(service: HydrationServiceProtocol) {
        self.service = service
    }

    func onAppear() async {
        await loadData()
    }

    func showAddEntry() {
        addEntryViewModel = AddEntryViewModel(service: service)
    }

    func onEntryAdded() {
        addEntryViewModel = nil
        Task {
            await loadData()
        }
    }

    private func loadData() async {
        await fetchTodayTotal()
        await fetchSevenDayHistory()
    }

    private func fetchTodayTotal() async {
        do {
            todayTotal = try await service.fetchTodayTotal()
        } catch {
            todayTotal = 0
        }
    }

    private func fetchSevenDayHistory() async {
        do {
            let calendar = Calendar.current
            let endDate = calendar.startOfDay(for: Date())
            let startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!

            dailyTotals = try await service.fetchDailyTotals(from: startDate, to: endDate)
        } catch {
            dailyTotals = [:]
        }
    }
}
