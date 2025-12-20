import SwiftUI

struct EntryRow: View {
    let entry: HydrationEntry

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
        Text("\(entry.volume.formattedLiters()) L")
            .font(.body)
            .foregroundStyle(.secondary)
    }
}
