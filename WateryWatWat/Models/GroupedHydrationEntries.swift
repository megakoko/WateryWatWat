import Foundation

struct GroupedHydrationEntries: Identifiable, Equatable {
    let date: Date
    let entries: [HydrationEntry]

    var id: Date { date }

    var totalVolume: Int64 {
        entries.reduce(0) { $0 + $1.volume }
    }

    var formattedTotalVolume: String {
        VolumeFormatter(unit: .liters).string(from: totalVolume)
    }

    static func == (lhs: GroupedHydrationEntries, rhs: GroupedHydrationEntries) -> Bool {
        lhs.date == rhs.date && lhs.entries == rhs.entries
    }
}
