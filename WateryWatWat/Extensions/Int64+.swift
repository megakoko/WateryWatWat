import Foundation

extension Int64 {
    var liters: Double {
        Double(self) / 1000.0
    }

    func formattedLiters() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: liters)) ?? "\(liters)"
    }
}
