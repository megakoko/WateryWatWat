import Foundation
import CoreData

final class MockHydrationService: HydrationServiceProtocol {
    private let delay: TimeInterval
    private let fail: Bool
    private let context: NSManagedObjectContext

    init(delay: TimeInterval = 0, fail: Bool = false) {
        self.delay = delay
        self.fail = fail
        self.context = PersistenceController.preview.container.viewContext
    }

    func addEntry(volume: Int64, type: String, date: Date) async throws {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }
    }

    func fetchDailyTotals(from startDate: Date, to endDate: Date) async throws -> [DailyTotal] {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }

        let calendar = Calendar.current
        var totals: [DailyTotal] = []

        var currentDate = startDate
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            totals.append(DailyTotal(date: dayStart, volume: Int64.random(in: 500...2500)))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return totals
    }

    func fetchTodayTotal() async throws -> Int64 {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }
        return 1750
    }

    func calculateStreak(goal: Int64) async throws -> Int {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }
        return 5
    }

    func fetchEntries(from startDate: Date, to endDate: Date) async throws -> [HydrationEntry] {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }

        var mockEntries: [HydrationEntry] = []
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: endDate)

        while currentDate >= startDate {
            let entriesCount = Int.random(in: 2...5)

            for i in 0..<entriesCount {
                let entry = HydrationEntry(context: context)
                entry.date = calendar.date(byAdding: .hour, value: 8 + i * 3, to: currentDate)
                entry.volume = [250, 500, 750, 1000].randomElement()!
                entry.type = "water"
                mockEntries.append(entry)
            }

            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }

        return mockEntries.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }

    func deleteEntry(_ entry: HydrationEntry) async throws {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }
    }

    func updateEntry(_ entry: HydrationEntry, volume: Int64, date: Date) async throws {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }
    }
}
