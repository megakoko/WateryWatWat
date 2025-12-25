import Foundation
import CoreData

final class MockHydrationService: HydrationService {
    private let delay: TimeInterval
    private let fail: Bool
    private let context: NSManagedObjectContext
    private let mockDailyTotals: [Date: Int64]
    private let mockEntries: [HydrationEntry]

    init(delay: TimeInterval = 0, fail: Bool = false) {
        self.delay = delay
        self.fail = fail
        self.context = PersistenceController.preview.container.viewContext

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var dailyTotals: [Date: Int64] = [:]
        var entries: [HydrationEntry] = []

        for dayOffset in 0..<30 {
            guard let currentDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let dayStart = calendar.startOfDay(for: currentDate)

            let entryCount = Int.random(in: 2...5)
            var dayTotal: Int64 = 0

            for i in 0..<entryCount {
                let entry = HydrationEntry(context: context)
                entry.date = calendar.date(byAdding: .hour, value: 8 + i * 3, to: dayStart)

                if dayOffset == 0 {
                    entry.volume = [200, 250, 300].randomElement()!
                } else {
                    entry.volume = [250, 500, 750, 1000].randomElement()!
                }

                entry.type = "water"
                entries.append(entry)
                dayTotal += entry.volume
            }

            dailyTotals[dayStart] = dayTotal
        }

        self.mockDailyTotals = dailyTotals
        self.mockEntries = entries.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
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
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)

        return mockDailyTotals
            .filter { date, _ in date >= startDay && date <= endDay }
            .map { DailyTotal(date: $0.key, volume: $0.value) }
            .sorted { $0.date < $1.date }
    }

    func fetchTodayTotal() async throws -> Int64 {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return mockDailyTotals[today] ?? 0
    }

    func calculateStreak(goal: Int64) async throws -> Int {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0

        for dayOffset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today),
                  let total = mockDailyTotals[date] else { break }

            if total >= goal {
                streak += 1
            } else {
                break
            }
        }

        return streak
    }

    func fetchEntries(from startDate: Date, to endDate: Date) async throws -> [HydrationEntry] {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }

        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)

        return mockEntries.filter { entry in
            guard let date = entry.date else { return false }
            let day = calendar.startOfDay(for: date)
            return day >= startDay && day <= endDay
        }
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
