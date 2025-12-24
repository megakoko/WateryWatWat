import SwiftUI

struct EntryCard: View {
    let entry: HydrationEntry
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    let volumeFormatter = VolumeFormatter(unit: .liters)

    init(entry: HydrationEntry, onEdit: (() -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.entry = entry
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    var body: some View {
        VStack(spacing: 8) {
            volumeText
            timeText
        }
        .padding(.vertical, 8)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contextMenu {
            if let onEdit {
                Button("Edit", systemImage: "pencil", action: onEdit)
            }
            if let onDelete {
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            }
        }
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
