import Foundation

protocol HealthKitServiceProtocol: Sendable {
    func requestAuthorization() async throws
    func isAuthorized() async -> Bool
    func saveDietaryWater(volume: Int64, date: Date) async throws
    func deleteAllRecords() async throws -> Int
}
