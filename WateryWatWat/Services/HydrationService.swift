import Foundation
import CoreData

protocol HydrationServiceProtocol {
    func addEntry(volume: Int64, type: String, date: Date) async throws
    func fetchDailyTotals(from startDate: Date, to endDate: Date) async throws -> [Date: Int64]
    func fetchTodayTotal() async throws -> Int64
    func calculateStreak(goal: Int64) async throws -> Int
    func fetchEntries(from startDate: Date, to endDate: Date) async throws -> [HydrationEntry]
    func deleteEntry(_ entry: HydrationEntry) async throws
}

final class HydrationService: HydrationServiceProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addEntry(volume: Int64, type: String = "water", date: Date = Date()) async throws {
        try await context.perform {
            let entry = HydrationEntry(context: self.context)
            entry.date = date
            entry.volume = volume
            entry.type = type
            try self.context.save()
        }
    }

    func fetchDailyTotals(from startDate: Date, to endDate: Date) async throws -> [Date: Int64] {
        try await context.perform {
            let calendar = Calendar.current
            let normalizedStart = calendar.startOfDay(for: startDate)
            let normalizedEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!

            let request = HydrationEntry.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@", normalizedStart as NSDate, normalizedEnd as NSDate)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \HydrationEntry.date, ascending: true)]

            let entries = try self.context.fetch(request)

            var dailyTotals: [Date: Int64] = [:]

            for entry in entries {
                let dayStart = calendar.startOfDay(for: entry.date!)
                dailyTotals[dayStart, default: 0] += entry.volume
            }

            return dailyTotals
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
            var currentDate = calendar.startOfDay(for: Date())
            var streak = 0

            while true {
                let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate)!

                let request = HydrationEntry.fetchRequest()
                request.predicate = NSPredicate(format: "date >= %@ AND date < %@", currentDate as NSDate, nextDay as NSDate)

                let entries = try self.context.fetch(request)
                let dailyTotal = entries.reduce(0) { $0 + $1.volume }

                if dailyTotal >= goal {
                    streak += 1
                    guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                    currentDate = previousDate
                } else {
                    break
                }
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
}
