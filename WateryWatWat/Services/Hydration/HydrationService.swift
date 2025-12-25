import Foundation
import CoreData

protocol HydrationServiceProtocol {
    func addEntry(volume: Int64, type: String, date: Date) async throws
    func fetchDailyTotals(from startDate: Date, to endDate: Date) async throws -> [DailyTotal]
    func fetchTodayTotal() async throws -> Int64
    func calculateStreak(goal: Int64) async throws -> Int
    func fetchEntries(from startDate: Date, to endDate: Date) async throws -> [HydrationEntry]
    func deleteEntry(_ entry: HydrationEntry) async throws
    func updateEntry(_ entry: HydrationEntry, volume: Int64, date: Date) async throws
}

final class HydrationService: HydrationServiceProtocol {
    private let context: NSManagedObjectContext
    private let healthKitService: HealthKitServiceProtocol
    private let settingsService: SettingsServiceProtocol

    init(context: NSManagedObjectContext, healthKitService: HealthKitServiceProtocol, settingsService: SettingsServiceProtocol) {
        self.context = context
        self.healthKitService = healthKitService
        self.settingsService = settingsService
    }

    func addEntry(volume: Int64, type: String = "water", date: Date = Date()) async throws {
        try await context.perform {
            let entry = HydrationEntry(context: self.context)
            entry.date = date
            entry.volume = volume
            entry.type = type
            try self.context.save()
        }

        if settingsService.getHealthSyncEnabled() {
            try? await healthKitService.saveDietaryWater(volume: volume, date: date)
        }
    }

    func fetchDailyTotals(from startDate: Date, to endDate: Date) async throws -> [DailyTotal] {
        try await context.perform {
            let calendar = Calendar.current
            let normalizedStart = calendar.startOfDay(for: startDate)
            let normalizedEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!

            let request = HydrationEntry.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@", normalizedStart as NSDate, normalizedEnd as NSDate)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \HydrationEntry.date, ascending: true)]

            let entries = try self.context.fetch(request)

            var totalsDict: [Date: Int64] = [:]
            for entry in entries {
                let dayStart = calendar.startOfDay(for: entry.date!)
                totalsDict[dayStart, default: 0] += entry.volume
            }

            var allDates: [DailyTotal] = []
            var currentDate = normalizedStart
            while currentDate <= calendar.startOfDay(for: endDate) {
                allDates.append(DailyTotal(date: currentDate, volume: totalsDict[currentDate] ?? 0))
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }

            return allDates
        }
    }

    func fetchTodayTotal() async throws -> Int64 {
        try await context.perform {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            let request = HydrationEntry.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)

            let entries = try self.context.fetch(request)
            return entries.reduce(0) { $0 + $1.volume }
        }
    }

    func calculateStreak(goal: Int64) async throws -> Int {
        try await context.perform {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            var currentDate = today
            var streak = 0

            while true {
                let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate)!

                let request = HydrationEntry.fetchRequest()
                request.predicate = NSPredicate(format: "date >= %@ AND date < %@", currentDate as NSDate, nextDay as NSDate)

                let entries = try self.context.fetch(request)
                let dailyTotal = entries.reduce(0) { $0 + $1.volume }

                if dailyTotal >= goal {
                    streak += 1
                } else if currentDate != today {
                    break
                }

                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            }

            return streak
        }
    }

    func fetchEntries(from startDate: Date, to endDate: Date) async throws -> [HydrationEntry] {
        try await context.perform {
            let calendar = Calendar.current
            let normalizedStart = calendar.startOfDay(for: startDate)
            let normalizedEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!

            let request = HydrationEntry.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@", normalizedStart as NSDate, normalizedEnd as NSDate)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \HydrationEntry.date, ascending: false)]

            return try self.context.fetch(request)
        }
    }

    func deleteEntry(_ entry: HydrationEntry) async throws {
        try await context.perform {
            self.context.delete(entry)
            try self.context.save()
        }
    }

    func updateEntry(_ entry: HydrationEntry, volume: Int64, date: Date) async throws {
        try await context.perform {
            entry.volume = volume
            entry.date = date
            try self.context.save()
        }
    }
}
