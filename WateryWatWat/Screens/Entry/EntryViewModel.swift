import Foundation

// MARK: - EntryViewModel

@Observable
final class EntryViewModel: Identifiable {
    let id = UUID()
    var selectedVolume: Int64?
    var selectedDate = Date()
    var isLoading = false
    var error: Error?

    var onEntryAdded: (() -> Void)?
    let availableVolumes = Constants.standardVolumes
    var showCustomPicker = false
    var customVolume: Int64 = 100

    private let service: HydrationService
    private let entry: HydrationEntry?
    private let volumeFormatter = VolumeFormatter(unit: .milliliters)

    var isEditing: Bool {
        entry != nil
    }

    var volumeUnit: String {
        volumeFormatter.formattedComponents(from: 0).unit
    }

    var volumeRows: [[Int64]] {
        stride(from: 0, to: availableVolumes.count, by: 3).map { index in
            Array(availableVolumes[index ..< min(index + 3, availableVolumes.count)])
        }
    }

    var canConfirm: Bool {
        (selectedVolume != nil || showCustomPicker) && !isLoading
    }

    init(service: HydrationService, entry: HydrationEntry? = nil) {
        self.service = service
        self.entry = entry
        if let entry {
            selectedDate = entry.date ?? Date()

            if availableVolumes.contains(entry.volume) {
                selectedVolume = entry.volume
            } else {
                customVolume = entry.volume
                showCustomPicker = true
            }
        }
    }

    func formattedVolume(for volume: Int) -> String {
        volumeFormatter.string(from: Int64(volume))
    }

    func formattedVolumeValue(for volume: Int64) -> String {
        volumeFormatter.formattedComponents(from: volume).value
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

    func confirmWithCustom() {
        if showCustomPicker {
            selectedVolume = customVolume
        }
        Task {
            await confirm()
        }
    }

    func confirm() async {
        guard let volume = selectedVolume else {
            return
        }

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

// MARK: Hashable

extension EntryViewModel: Hashable {
    static func == (lhs: EntryViewModel, rhs: EntryViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
