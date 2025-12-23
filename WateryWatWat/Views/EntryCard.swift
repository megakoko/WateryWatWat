import SwiftUI

struct EntryCard: View {
    let entry: HydrationEntry
    let volumeFormatter = VolumeFormatter(unit: .liters)

    var body: some View {
        VStack(spacing: 8) {
            volumeText
            timeText
        }
        .padding(.vertical, 8)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var volumeText: some View {
        Text(volumeFormatter.string(from: entry.volume))
            .font(.headline)
    }

    private var timeText: some View {
        Text(entry.date ?? Date(), format: .dateTime.hour().minute())
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
