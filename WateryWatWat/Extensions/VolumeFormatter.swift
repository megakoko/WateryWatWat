import Foundation

final class VolumeFormatter {
    let unit: UnitVolume

    var symbol: String {
        unit.symbol
    }

    private lazy var measurementFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        return formatter
    }()

    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    init(unit: UnitVolume) {
        self.unit = unit
    }

    func string(from volumeML: Int64) -> String {
        let value: Double
        if unit == .milliliters {
            value = Double(volumeML)
        } else {
            value = Double(volumeML) / 1000.0
        }

        let measurement = Measurement(value: value, unit: unit)
        return measurementFormatter.string(from: measurement)
    }

    func formattedValue(from volumeML: Int64) -> String {
        let value: Double
        if unit == .milliliters {
            value = Double(volumeML)
        } else {
            value = Double(volumeML) / 1000.0
        }

        return numberFormatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
