import Foundation

protocol HealthKitServiceProtocol: Sendable {
    func requestAuthorization() async throws
    func isAuthorized() async -> Bool
    func saveDietaryWater(volume: Int64, date: Date) async throws -> String
    func deleteAllRecords() async throws -> Int
    func deleteDietaryWater(uuid: String) async throws
}
