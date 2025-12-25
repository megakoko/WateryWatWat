import Foundation

protocol HydrationServiceProtocol {
    func addEntry(volume: Int64, type: String, date: Date) async throws
    func fetchDailyTotals(from startDate: Date, to endDate: Date) async throws -> [DailyTotal]
    func fetchTodayTotal() async throws -> Int64
    func calculateStreak(goal: Int64) async throws -> Int
    func fetchEntries(from startDate: Date, to endDate: Date) async throws -> [HydrationEntry]
    func deleteEntry(_ entry: HydrationEntry) async throws
    func updateEntry(_ entry: HydrationEntry, volume: Int64, date: Date) async throws
}
