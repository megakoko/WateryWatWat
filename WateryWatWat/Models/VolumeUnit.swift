import Foundation

enum VolumeUnit: String, Codable, Sendable {
    case ml
    case oz

    var conversionFactorToML: Double {
        switch self {
        case .ml: return 1.0
        case .oz: return 29.5735
        }
    }
}
