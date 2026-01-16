import SwiftUI
import Charts

struct HistoryChartView: View {
    let dailyTotals: [DailyTotal]
    let goalPeriods: [GoalPeriod]
    let periodDays: Int
    let onTogglePeriod: () -> Void

    private let calendar = Calendar.current
    private let volumeFormatter = VolumeFormatter(unit: .liters)

    var body: some View {
        Chart {
            ForEach(dailyTotals, id: \.date) { total in
                BarMark(
                    x: .value("Day", total.date, unit: .day),
                    y: .value("Volume", total.volume)
                )
                .foregroundStyle(Color.accentColor)
                .cornerRadius(periodDays == 7 ? 8 : 2)
            }

            ForEach(goalPeriods, id: \.start) { period in
                RuleMark(xStart: .value("Start", period.start), xEnd: .value("End", period.end), y: .value("Goal", period.value))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [10, 5]))
                    .foregroundStyle(Color.init(uiColor: .secondaryLabel))
            }
        }
        .chartXAxis {
            if periodDays == 7 {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                }
            } else {
                AxisMarks(values: xAxisValues) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(labelForDate(date))
                        }
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: goalPeriods.map { Double($0.value) }) { value in
                AxisValueLabel {
                    if let goalValue = value.as(Double.self) {
                        Text(volumeFormatter.string(from: Int64(goalValue)))
                            .textCase(.uppercase)
                    }
                }
            }
        }
        .frame(height: 100)
    }

    private var xAxisValues: [Date] {
        let today = calendar.startOfDay(for: Date())
        return [
            calendar.date(byAdding: .day, value: -28, to: today)!,
            calendar.date(byAdding: .day, value: -21, to: today)!,
            calendar.date(byAdding: .day, value: -14, to: today)!,
            calendar.date(byAdding: .day, value: -7, to: today)!,
        ]
    }

    private func labelForDate(_ date: Date) -> String {
        let today = calendar.startOfDay(for: Date())
        if calendar.isDate(date, inSameDayAs: today) {
            return "0"
        }
        let weeksAgo = calendar.dateComponents([.weekOfYear], from: date, to: today).weekOfYear ?? 0
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.weekOfMonth]
        formatter.unitsStyle = .abbreviated
        let interval = TimeInterval(weeksAgo * 7 * 24 * 60 * 60)
        return formatter.string(from: interval) ?? "\(weeksAgo)w"
    }
}

#Preview {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let dailyTotals: [DailyTotal] = [
        DailyTotal(date: calendar.date(byAdding: .day, value: -6, to: today)!, volume: 800),
        DailyTotal(date: calendar.date(byAdding: .day, value: -5, to: today)!, volume: 1200),
        DailyTotal(date: calendar.date(byAdding: .day, value: -4, to: today)!, volume: 1500),
        DailyTotal(date: calendar.date(byAdding: .day, value: -3, to: today)!, volume: 2000),
        DailyTotal(date: calendar.date(byAdding: .day, value: -2, to: today)!, volume: 1800),
        DailyTotal(date: calendar.date(byAdding: .day, value: -1, to: today)!, volume: 2200),
        DailyTotal(date: today, volume: 1750)
    ]
    let goalPeriods: [GoalPeriod] = [
        GoalPeriod(start: calendar.date(byAdding: .day, value: -6, to: today)!, end: calendar.date(byAdding: .day, value: -3, to: today)!, value: 1800),
        GoalPeriod(start: calendar.date(byAdding: .day, value: -3, to: today)!, end: today, value: 2000)
    ]

    return ScrollView {
        VStack(spacing: 20) {
            HistoryChartView(dailyTotals: dailyTotals, goalPeriods: goalPeriods, periodDays: 7, onTogglePeriod: {})
            HistoryChartView(dailyTotals: dailyTotals, goalPeriods: goalPeriods, periodDays: 30, onTogglePeriod: {})
        }
        .padding()
    }
}

// MARK: - GoalPeriod

struct GoalPeriod {
    let start: Date
    let end: Date
    let value: Int64
}
