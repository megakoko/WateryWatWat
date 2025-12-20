import Foundation

struct GroupedHydrationEntries: Identifiable, Equatable {
    let date: Date
    let entries: [HydrationEntry]

    var id: Date { date }

    var totalVolume: Int64 {
        entries.reduce(0) { $0 + $1.volume }
    }

    static func == (lhs: GroupedHydrationEntries, rhs: GroupedHydrationEntries) -> Bool {
        lhs.date == rhs.date
    }
}
