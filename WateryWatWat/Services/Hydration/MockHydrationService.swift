import Foundation
import CoreData

final class MockHydrationService: HydrationService {
    private let delay: TimeInterval
    private let fail: Bool
    private let context: NSManagedObjectContext
    private let mockDailyTotals: [Date: Int64]
    private let mockEntries: [HydrationEntry]
    private var goalHistory: [(effectiveDate: Date, value: Int64)] = []

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

                entry.type = EntryType.water.rawValue
                entry.unit = VolumeUnit.ml.rawValue
                entries.append(entry)
                dayTotal += entry.volume
            }

            dailyTotals[dayStart] = dayTotal
        }

        self.mockDailyTotals = dailyTotals
        self.mockEntries = entries.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }

    func addEntry(volume: Int64, type: EntryType, unit: VolumeUnit, date: Date) async throws {
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

    func calculateStreak() async throws -> Int {
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

            let goalForDay = goalHistory.last { $0.effectiveDate <= date }?.value ?? Constants.defaultDailyGoalML

            if total >= goalForDay {
                streak += 1
            } else if dayOffset > 0 {
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

    func updateEntry(_ entry: HydrationEntry, volume: Int64, type: EntryType, unit: VolumeUnit, date: Date) async throws {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }
    }

    func duplicateEntry(_ entry: HydrationEntry) async throws {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }
    }

    func setDailyGoal(_ value: Int64, effectiveDate: Date) async throws {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }

        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: effectiveDate)

        if let index = goalHistory.firstIndex(where: { $0.effectiveDate == normalizedDate }) {
            goalHistory[index] = (normalizedDate, value)
        } else {
            goalHistory.append((normalizedDate, value))
            goalHistory.sort { $0.effectiveDate < $1.effectiveDate }
        }
    }

    func getDailyGoal() async throws -> Int64 {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }

        return goalHistory.last?.value ?? Constants.defaultDailyGoalML
    }

    func isGoalSet() -> Bool {
        !goalHistory.isEmpty
    }

    func fetchGoalPeriods(from startDate: Date, to endDate: Date) async throws -> [GoalPeriod] {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }

        let calendar = Calendar.current
        let normalizedStart = calendar.startOfDay(for: startDate)
        let normalizedEnd = calendar.startOfDay(for: endDate)

        guard let firstGoal = goalHistory.first else {
            return []
        }

        let goalBeforeRange = goalHistory.last { $0.effectiveDate < normalizedStart }
        let goalsInRange = goalHistory.filter { $0.effectiveDate >= normalizedStart && $0.effectiveDate <= normalizedEnd }

        var periods: [GoalPeriod] = []
        var currentStart = normalizedStart
        var currentValue = goalBeforeRange?.value ?? firstGoal.value

        for goal in goalsInRange {
            if goal.effectiveDate > currentStart {
                let periodEnd = calendar.date(byAdding: .day, value: -1, to: goal.effectiveDate)!
                periods.append(GoalPeriod(start: currentStart, end: periodEnd, value: currentValue))
            }
            currentStart = goal.effectiveDate
            currentValue = goal.value
        }

        periods.append(GoalPeriod(start: currentStart, end: normalizedEnd, value: currentValue))

        return periods
    }
}
