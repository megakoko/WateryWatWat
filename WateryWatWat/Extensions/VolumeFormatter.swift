import Foundation

final class VolumeFormatter {
    let unit: UnitVolume
    let locale: Locale

    private lazy var measurementFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.locale = locale
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        return formatter
    }()

    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    init(unit: UnitVolume) {
        self.unit = unit
        self.locale = .current
    }

    init(unit: UnitVolume, locale: Locale) {
        self.unit = unit
        self.locale = locale
    }

    func formattedComponents(from volumeML: Int64) -> FormattedVolume {
        let value = convert(volumeML: volumeML)

        let valueString = numberFormatter.string(from: NSNumber(value: value)) ?? "0"

        let probeValue = 1.0
        let probeMeasurement = Measurement(value: probeValue, unit: unit)
        let probeString = measurementFormatter.string(from: probeMeasurement)

        let probeNumber = measurementFormatter.numberFormatter.string(from: NSNumber(value: probeValue)) ?? "1"

        let unitString = probeString
            .replacingOccurrences(of: probeNumber, with: "")
            .trimmingCharacters(in: .whitespaces)

        let unitPosition: UnitPosition = probeString.hasPrefix(probeNumber) ? .afterValue : .beforeValue

        return FormattedVolume(
            value: valueString,
            unit: unitString,
            unitPosition: unitPosition
        )
    }

    func string(from volumeML: Int64) -> String {
        let value = convert(volumeML: volumeML)
        let measurement = Measurement(value: value, unit: unit)
        return measurementFormatter.string(from: measurement)
    }

    private func convert(volumeML: Int64) -> Double {
        if unit == .milliliters {
            return Double(volumeML)
        } else {
            return Double(volumeML) / 1000.0
        }
    }
}

// MARK: - Unit position

enum UnitPosition {
    case beforeValue
    case afterValue
}

// MARK: - Formatted volume

struct FormattedVolume {
    let value: String
    let unit: String
    let unitPosition: UnitPosition
}
