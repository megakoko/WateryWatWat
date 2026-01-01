import Foundation

@Observable
final class EntryViewModel: Identifiable {
    let id = UUID()
    var selectedVolume: Int64?
    var selectedDate = Date()
    var isLoading = false
    var error: Error?

    private let service: HydrationService
    private let entry: HydrationEntry?
    var onEntryAdded: (() -> Void)?

    let availableVolumes = Constants.standardVolumes
    var showCustomPicker = false
    var customVolume: Int64 = 100

    var isEditing: Bool {
        entry != nil
    }

    init(service: HydrationService, entry: HydrationEntry? = nil) {
        self.service = service
        self.entry = entry
        if let entry {
            self.selectedDate = entry.date ?? Date()

            if availableVolumes.contains(entry.volume) {
                self.selectedVolume = entry.volume
            } else {
                self.customVolume = entry.volume
                self.showCustomPicker = true
            }
        }
    }

    func selectVolume(_ volume: Int64) {
        selectedVolume = volume
        showCustomPicker = false
    }

    func selectCustom() {
        if let selectedVolume {
            customVolume = selectedVolume
        }
        showCustomPicker = true
        selectedVolume = nil
    }

    var canConfirm: Bool {
        (selectedVolume != nil || showCustomPicker) && !isLoading
    }

    func confirmWithCustom() {
        if showCustomPicker {
            selectedVolume = customVolume
        }
        Task {
            await confirm()
        }
    }

    func confirm() async {
        guard let volume = selectedVolume else { return }

        isLoading = true
        do {
            if let entry {
                try await service.updateEntry(entry, volume: volume, date: selectedDate)
            } else {
                try await service.addEntry(volume: volume, type: .water, date: selectedDate)
            }
            onEntryAdded?()
        } catch {
            self.error = error
            isLoading = false
            return
        }
        isLoading = false
    }

    func cancel() {
        onEntryAdded?()
    }
}

extension EntryViewModel: Hashable {
    static func == (lhs: EntryViewModel, rhs: EntryViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
