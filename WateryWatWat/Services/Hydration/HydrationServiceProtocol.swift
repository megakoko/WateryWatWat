import Foundation

protocol HydrationService {
    func addEntry(volume: Int64, type: EntryType, unit: VolumeUnit, date: Date) async throws
    func fetchDailyTotals(from startDate: Date, to endDate: Date) async throws -> [DailyTotal]
    func fetchTodayTotal() async throws -> Int64
    func calculateStreak(goal: Int64) async throws -> Int
    func fetchEntries(from startDate: Date, to endDate: Date) async throws -> [HydrationEntry]
    func deleteEntry(_ entry: HydrationEntry) async throws
    func updateEntry(_ entry: HydrationEntry, volume: Int64, type: EntryType, unit: VolumeUnit, date: Date) async throws
}

extension HydrationService {
    func addEntry(volume: Int64, type: EntryType = .water, unit: VolumeUnit = .ml, date: Date = Date()) async throws {
        try await addEntry(volume: volume, type: type, unit: unit, date: date)
    }

    func updateEntry(_ entry: HydrationEntry, volume: Int64, type: EntryType = .water, unit: VolumeUnit = .ml, date: Date) async throws {
        try await updateEntry(entry, volume: volume, type: type, unit: unit, date: date)
    }
}
