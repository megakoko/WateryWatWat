import Foundation
import CoreData

final class DefaultHydrationService {
    private let persistenceController: PersistenceController
    private let healthKitService: HealthKitService
    private let settingsService: SettingsService

    private var context: NSManagedObjectContext {
        persistenceController.container.viewContext
    }

    init(persistenceController: PersistenceController, healthKitService: HealthKitService, settingsService: SettingsService) {
        self.persistenceController = persistenceController
        self.healthKitService = healthKitService
        self.settingsService = settingsService
    }
}

extension DefaultHydrationService: HydrationService {
    func addEntry(volume: Int64, type: EntryType, unit: VolumeUnit, date: Date) async throws {
        var objectIDString: String?

        try await context.perform {
            let entry = HydrationEntry(context: self.context)
            entry.date = date
            entry.volume = volume
            entry.type = type.rawValue
            entry.unit = unit.rawValue
            try self.context.save()

            objectIDString = entry.objectID.uriRepresentation().absoluteString
        }

        if let objectID = objectIDString, settingsService.getHealthSyncEnabled() {
            try? await healthKitService.saveDietaryWater(volume: volume, date: date, coreDataID: objectID)
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

    func calculateStreak() async throws -> Int {
        try await context.perform {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            var currentDate = today
            var streak = 0

            let goalRequest = DailyGoal.fetchRequest()
            goalRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DailyGoal.effectiveDateString, ascending: false)]
            let allGoals = try self.context.fetch(goalRequest)

            while true {
                let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                let dateString = Self.dateFormatter.string(from: currentDate)

                let goalForDay = allGoals.first { ($0.effectiveDateString ?? "") <= dateString }?.value ?? Constants.defaultDailyGoalML

                let request = HydrationEntry.fetchRequest()
                request.predicate = NSPredicate(format: "date >= %@ AND date < %@", currentDate as NSDate, nextDay as NSDate)

                let entries = try self.context.fetch(request)
                let dailyTotal = entries.reduce(0) { $0 + $1.volume }

                if dailyTotal >= goalForDay {
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
        let objectIDString = entry.objectID.uriRepresentation().absoluteString

        try await context.perform {
            self.context.delete(entry)
            try self.context.save()
        }

        if settingsService.getHealthSyncEnabled() {
            try? await healthKitService.deleteDietaryWater(coreDataID: objectIDString)
        }
    }

    func updateEntry(_ entry: HydrationEntry, volume: Int64, type: EntryType, unit: VolumeUnit, date: Date) async throws {
        let objectIDString = entry.objectID.uriRepresentation().absoluteString

        if settingsService.getHealthSyncEnabled() {
            try? await healthKitService.deleteDietaryWater(coreDataID: objectIDString)
        }

        try await context.perform {
            entry.volume = volume
            entry.type = type.rawValue
            entry.unit = unit.rawValue
            entry.date = date
            try self.context.save()
        }

        if settingsService.getHealthSyncEnabled() {
            try? await healthKitService.saveDietaryWater(volume: volume, date: date, coreDataID: objectIDString)
        }
    }

    func duplicateEntry(_ entry: HydrationEntry) async throws {
        guard
            let entryTypeString = entry.type,
            let entryType = EntryType(rawValue: entryTypeString),
            let entryUnitString = entry.unit,
            let entryUnit = VolumeUnit(rawValue: entryUnitString)
        else {
            return
        }

        try await addEntry(volume: entry.volume, type: entryType, unit: entryUnit, date: Date())
    }

    func setDailyGoal(_ value: Int64, effectiveDate: Date) async throws {
        let dateString = Self.dateFormatter.string(from: effectiveDate)

        try await context.perform {
            let request = DailyGoal.fetchRequest()
            request.predicate = NSPredicate(format: "effectiveDateString == %@", dateString)
            request.fetchLimit = 1

            let existing = try self.context.fetch(request).first

            if let existing {
                existing.value = value
                existing.unit = VolumeUnit.ml.rawValue
            } else {
                let goal = DailyGoal(context: self.context)
                goal.effectiveDateString = dateString
                goal.value = value
                goal.unit = VolumeUnit.ml.rawValue
            }

            try self.context.save()
        }
    }

    func getDailyGoal() async throws -> Int64 {
        try await context.perform {
            let request = DailyGoal.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyGoal.effectiveDateString, ascending: false)]
            request.fetchLimit = 1

            let goal = try self.context.fetch(request).first
            return goal?.value ?? Constants.defaultDailyGoalML
        }
    }

    func isGoalSet() -> Bool {
        var result = false
        context.performAndWait {
            let request = DailyGoal.fetchRequest()
            request.fetchLimit = 1
            result = (try? self.context.count(for: request) > 0) ?? false
        }
        return result
    }

    func fetchGoalPeriods(from startDate: Date, to endDate: Date) async throws -> [GoalPeriod] {
        try await context.perform {
            let calendar = Calendar.current
            let normalizedStart = calendar.startOfDay(for: startDate)
            let normalizedEnd = calendar.startOfDay(for: endDate)
            let startDateString = Self.dateFormatter.string(from: startDate)
            let endDateString = Self.dateFormatter.string(from: endDate)

            let request = DailyGoal.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyGoal.effectiveDateString, ascending: true)]

            let allGoals = try self.context.fetch(request)

            guard let firstGoal = allGoals.first else {
                return []
            }

            let goalBeforeRange = allGoals.last { ($0.effectiveDateString ?? "") < startDateString }
            let goalsInRange = allGoals.compactMap { goal -> (date: Date, value: Int64)? in
                guard let dateString = goal.effectiveDateString,
                      dateString >= startDateString && dateString <= endDateString,
                      let date = Self.dateFormatter.date(from: dateString) else { return nil }
                return (date, goal.value)
            }

            var periods: [GoalPeriod] = []
            var currentStart = normalizedStart
            var currentValue = goalBeforeRange?.value ?? firstGoal.value

            for goal in goalsInRange {
                if goal.date > currentStart {
                    let periodEnd = calendar.date(byAdding: .day, value: -1, to: goal.date)!
                    periods.append(GoalPeriod(start: currentStart, end: periodEnd, value: currentValue))
                }
                currentStart = goal.date
                currentValue = goal.value
            }

            periods.append(GoalPeriod(start: currentStart, end: normalizedEnd, value: currentValue))

            return periods
        }
    }

    func fetchFrequentVolumes(excluding standardVolumes: [Int64], limit: Int) async throws -> [Int64] {
        try await context.perform {
            let request = NSFetchRequest<NSDictionary>(entityName: "HydrationEntry")
            request.resultType = .dictionaryResultType
            let volumeDesc = NSExpressionDescription()
            volumeDesc.name = "volume"
            volumeDesc.expression = NSExpression(forKeyPath: "volume")
            volumeDesc.expressionResultType = .integer64AttributeType
            let countDesc = NSExpressionDescription()
            countDesc.name = "count"
            countDesc.expression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: "volume")])
            countDesc.expressionResultType = .integer64AttributeType
            request.propertiesToFetch = [volumeDesc, countDesc]
            request.propertiesToGroupBy = ["volume"]
            request.predicate = NSPredicate(format: "NOT (volume IN %@)", standardVolumes)
            request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false)]
            let results = try self.context.fetch(request)
            return results
                .filter { ($0["count"] as? Int64 ?? 0) >= 5 }
                .prefix(limit)
                .compactMap { $0["volume"] as? Int64 }
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
