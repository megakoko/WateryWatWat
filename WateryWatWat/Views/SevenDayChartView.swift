import SwiftUI
import Charts

struct SevenDayChartView: View {
    let dailyTotals: [DailyTotal]
    let dailyGoal: Int64
    let periodDays: Int
    let onTogglePeriod: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        Chart {
            ForEach(dailyTotals, id: \.date) { total in
                BarMark(
                    x: .value("Day", total.date, unit: .day),
                    y: .value("Volume", total.volume)
                )
                .foregroundStyle(Color.aquaBlue)
                .cornerRadius(periodDays == 7 ? 8 : 2)
            }

            RuleMark(y: .value("Goal", dailyGoal))
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [10, 5]))
                .foregroundStyle(Color.init(uiColor: .secondaryLabel))
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
            AxisMarks(values: [Double(dailyGoal)]) { _ in
                AxisValueLabel()
            }
        }
        .frame(height: 100)
    }

    private var xAxisValues: [Date] {
        let today = calendar.startOfDay(for: Date())
        return [
            calendar.date(byAdding: .day, value: -21, to: today)!,
            calendar.date(byAdding: .day, value: -14, to: today)!,
            calendar.date(byAdding: .day, value: -7, to: today)!,
            today,
        ]
    }

    private func labelForDate(_ date: Date) -> String {
        let today = calendar.startOfDay(for: Date())
        if calendar.isDate(date, inSameDayAs: today) {
            return "0"
        }
        let weeksAgo = calendar.dateComponents([.weekOfYear], from: date, to: today).weekOfYear ?? 0
        return "\(weeksAgo)w"
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

    return ScrollView {
        VStack(spacing: 20) {
            SevenDayChartView(dailyTotals: dailyTotals, dailyGoal: 2000, periodDays: 7, onTogglePeriod: {})
            SevenDayChartView(dailyTotals: dailyTotals, dailyGoal: 2000, periodDays: 30, onTogglePeriod: {})
        }
        .padding()
    }
}
