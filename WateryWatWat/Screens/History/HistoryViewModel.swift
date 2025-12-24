import Foundation
import CoreData

@Observable
final class HistoryViewModel: Identifiable {
    let id = UUID()
    var groupedEntries: [GroupedHydrationEntries] = []
    var editEntryViewModel: AddEntryViewModel?
    var error: Error?

    private let service: HydrationServiceProtocol

    init(service: HydrationServiceProtocol) {
        self.service = service
    }

    func onAppear() async {
        await fetchEntries()
    }

    func deleteEntry(_ entry: HydrationEntry) async {
        do {
            try await service.deleteEntry(entry)
            await fetchEntries()
        } catch {
            self.error = error
        }
    }

    func onDidTap(_ entry: HydrationEntry) {
        editEntryViewModel = AddEntryViewModel(service: service, entry: entry)
    }

    private func fetchEntries() async {
        do {
            let calendar = Calendar.current
            let endDate = calendar.startOfDay(for: Date())
            let startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!

            let entries = try await service.fetchEntries(from: startDate, to: endDate)

            var grouped: [Date: [HydrationEntry]] = [:]
            for entry in entries {
                let dayStart = calendar.startOfDay(for: entry.date!)
                grouped[dayStart, default: []].append(entry)
            }

            groupedEntries = grouped.map { date, entries in
                GroupedHydrationEntries(date: date, entries: entries)
            }.sorted { $0.date > $1.date }
        } catch {
            self.error = error
            groupedEntries = []
        }
    }
}

extension HistoryViewModel: Hashable {
    static func == (lhs: HistoryViewModel, rhs: HistoryViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
