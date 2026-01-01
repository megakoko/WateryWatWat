import Foundation
import CoreData

@Observable
final class HistoryViewModel: Identifiable {
    let id = UUID()
    var groupedEntries: [GroupedHydrationEntries] = []
    var editEntryViewModel: EntryViewModel?
    var error: Error?
    var entryToDelete: HydrationEntry?
    var showDeleteConfirmation = false

    var formattedVolumeToDelete: String {
        guard let entry = entryToDelete else { return "" }
        return volumeFormatter.string(from: entry.volume)
    }

    private let service: HydrationService
    private let volumeFormatter = VolumeFormatter(unit: .milliliters)

    init(service: HydrationService) {
        self.service = service
    }

    func onAppear() async {
        await fetchEntries()
    }

    func requestDelete(_ entry: HydrationEntry) {
        entryToDelete = entry
        showDeleteConfirmation = true
    }

    func confirmDelete() {
        guard let entry = entryToDelete else { return }
        showDeleteConfirmation = false
        entryToDelete = nil
        Task {
            await deleteEntry(entry)
        }
    }

    func onDidTap(_ entry: HydrationEntry) {
        editEntryViewModel = EntryViewModel(service: service, entry: entry)
    }

    private func deleteEntry(_ entry: HydrationEntry) async {
        do {
            try await service.deleteEntry(entry)
            await fetchEntries()
        } catch {
            self.error = error
        }
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
