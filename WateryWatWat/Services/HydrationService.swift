import Foundation
import CoreData

protocol HydrationServiceProtocol {
    func addEntry(volume: Int64, type: String) async throws
    func fetchDailyTotals(from startDate: Date, to endDate: Date) async throws -> [Date: Int64]
    func fetchTodayTotal() async throws -> Int64
}

final class HydrationService: HydrationServiceProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addEntry(volume: Int64, type: String = "water") async throws {
        try await context.perform {
            let entry = HydrationEntry(context: self.context)
            entry.date = Date()
            entry.volume = volume
            entry.type = type
            try self.context.save()
        }
    }

    func fetchDailyTotals(from startDate: Date, to endDate: Date) async throws -> [Date: Int64] {
        try await context.perform {
            let request = HydrationEntry.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \HydrationEntry.date, ascending: true)]

            let entries = try self.context.fetch(request)

            var dailyTotals: [Date: Int64] = [:]
            let calendar = Calendar.current

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
}
