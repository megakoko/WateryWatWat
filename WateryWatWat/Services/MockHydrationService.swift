import Foundation

final class MockHydrationService: HydrationServiceProtocol {
    private let delay: TimeInterval
    private let fail: Bool

    init(delay: TimeInterval = 0, fail: Bool = false) {
        self.delay = delay
        self.fail = fail
    }

    func addEntry(volume: Int64, type: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }
    }

    func fetchDailyTotals(from startDate: Date, to endDate: Date) async throws -> [Date: Int64] {
        try await Task.sleep(for: .seconds(delay))
        if fail {
            throw NSError(domain: "MockHydrationService", code: -1)
        }

        let calendar = Calendar.current
        var totals: [Date: Int64] = [:]

        var currentDate = startDate
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            totals[dayStart] = Int64.random(in: 500...2500)
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
}
