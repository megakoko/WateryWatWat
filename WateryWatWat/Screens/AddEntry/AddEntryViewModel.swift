import Foundation

@Observable
final class AddEntryViewModel: Identifiable {
    let id = UUID()
    var selectedVolume: Int64?
    var selectedDate = Date()
    var isLoading = false

    private let service: HydrationServiceProtocol
    private let entry: HydrationEntry?
    var onEntryAdded: (() -> Void)?

    let availableVolumes: [Int64] = [100, 200, 250, 500]

    var isEditing: Bool {
        entry != nil
    }

    init(service: HydrationServiceProtocol, entry: HydrationEntry? = nil) {
        self.service = service
        self.entry = entry
        if let entry {
            self.selectedVolume = entry.volume
            self.selectedDate = entry.date ?? Date()
        }
    }

    func selectVolume(_ volume: Int64) {
        selectedVolume = volume
    }

    func confirm() async {
        guard let volume = selectedVolume else { return }

        isLoading = true
        do {
            if let entry {
                try await service.updateEntry(entry, volume: volume, date: selectedDate)
            } else {
                try await service.addEntry(volume: volume, type: "water", date: selectedDate)
            }
            onEntryAdded?()
        } catch {
        }
        isLoading = false
    }
}

extension AddEntryViewModel: Hashable {
    static func == (lhs: AddEntryViewModel, rhs: AddEntryViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
