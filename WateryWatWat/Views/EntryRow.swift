import SwiftUI

struct EntryRow: View {
    let entry: HydrationEntry
    let volumeFormatter = VolumeFormatter(unit: .milliliters)

    var body: some View {
        HStack {
            timeText
            Spacer()
            volumeText
        }
    }

    private var timeText: some View {
        Text(entry.date ?? Date(), format: .dateTime.hour().minute())
            .font(.body)
    }

    private var volumeText: some View {
        Text(volumeFormatter.string(from: entry.volume))
            .font(.body)
            .foregroundStyle(.secondary)
    }
}
