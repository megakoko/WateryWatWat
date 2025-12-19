import Foundation

@Observable
final class AddEntryViewModel: Identifiable, Hashable {
    let id = UUID()

    static func == (lhs: AddEntryViewModel, rhs: AddEntryViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var selectedVolume: Int64?
    var isLoading = false

    private let service: HydrationServiceProtocol
    var onEntryAdded: (() -> Void)?

    let availableVolumes: [Int64] = [100, 200, 250, 500]

    init(service: HydrationServiceProtocol) {
        self.service = service
    }

    func selectVolume(_ volume: Int64) {
        selectedVolume = volume
    }

    func confirm() async {
        guard let volume = selectedVolume else { return }

        isLoading = true
        do {
            try await service.addEntry(volume: volume, type: "water")
            onEntryAdded?()
        } catch {
        }
        isLoading = false
    }
}
