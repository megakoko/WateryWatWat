import SwiftUI

struct SevenDayChartView: View {
    let dailyTotals: [Date: Int64]

    private let calendar = Calendar.current

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(lastSevenDays, id: \.self) { date in
                barView(for: date)
            }
        }
        .frame(height: 150)
    }

    private var lastSevenDays: [Date] {
        let endDate = calendar.startOfDay(for: Date())
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: endDate)
        }.reversed()
    }

    private var maxVolume: Int64 {
        dailyTotals.values.max() ?? 1
    }

    private func barView(for date: Date) -> some View {
        VStack(spacing: 4) {
            barRectangle(for: date)
            dayLabel(for: date)
        }
        .frame(maxWidth: .infinity)
    }

    private func barRectangle(for date: Date) -> some View {
        let volume = dailyTotals[date] ?? 0
        let height = maxVolume > 0 ? (Double(volume) / Double(maxVolume)) * 120 : 0

        return RoundedRectangle(cornerRadius: 4)
            .fill(.blue)
            .frame(height: max(height, 4))
            .frame(maxHeight: 120, alignment: .bottom)
    }

    private func dayLabel(for date: Date) -> some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        return Text(formatter.string(from: date))
            .font(.caption2)
    }
}

#Preview {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let dailyTotals: [Date: Int64] = [
        calendar.date(byAdding: .day, value: -6, to: today)!: 800,
        calendar.date(byAdding: .day, value: -5, to: today)!: 1200,
        calendar.date(byAdding: .day, value: -4, to: today)!: 1500,
        calendar.date(byAdding: .day, value: -3, to: today)!: 2000,
        calendar.date(byAdding: .day, value: -2, to: today)!: 1800,
        calendar.date(byAdding: .day, value: -1, to: today)!: 2200,
        today: 1750
    ]

    return SevenDayChartView(dailyTotals: dailyTotals)
        .padding()
}
