import SwiftUI
import Charts

struct SevenDayChartView: View {
    let dailyTotals: [Date: Int64]
    let dailyGoal: Int64
    let periodDays: Int
    let onTogglePeriod: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        Chart {
            ForEach(lastDays, id: \.self) { date in
                BarMark(
                    x: .value("Day", date, unit: .day),
                    y: .value("Volume", dailyTotals[calendar.startOfDay(for: date)] ?? 0)
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

    private var lastDays: [Date] {
        let endDate = calendar.startOfDay(for: Date())
        return (0..<periodDays).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: endDate)
        }.reversed()
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
    let dailyTotals: [Date: Int64] = [
        calendar.date(byAdding: .day, value: -6, to: today)!: 800,
        calendar.date(byAdding: .day, value: -5, to: today)!: 1200,
        calendar.date(byAdding: .day, value: -4, to: today)!: 1500,
        calendar.date(byAdding: .day, value: -3, to: today)!: 2000,
        calendar.date(byAdding: .day, value: -2, to: today)!: 1800,
        calendar.date(byAdding: .day, value: -1, to: today)!: 2200,
        today: 1750
    ]

    return ScrollView {
        VStack(spacing: 20) {
            SevenDayChartView(dailyTotals: dailyTotals, dailyGoal: 2000, periodDays: 7, onTogglePeriod: {})
            SevenDayChartView(dailyTotals: dailyTotals, dailyGoal: 2000, periodDays: 30, onTogglePeriod: {})
        }
        .padding()
    }
}
