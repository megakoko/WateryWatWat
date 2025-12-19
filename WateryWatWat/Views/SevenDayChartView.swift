import SwiftUI
import Charts

struct SevenDayChartView: View {
    let dailyTotals: [Date: Int64]
    let dailyGoal: Int64

    private let calendar = Calendar.current

    var body: some View {
        Chart {
            ForEach(lastSevenDays, id: \.self) { date in
                BarMark(
                    x: .value("Day", date, unit: .day),
                    y: .value("Volume", dailyTotals[calendar.startOfDay(for: date)] ?? 0)
                )
                .foregroundStyle(Color.aquaBlue)
                .cornerRadius(8)
            }

            RuleMark(y: .value("Goal", dailyGoal))
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [10, 5]))
                .foregroundStyle(Color.aquaBlue)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisValueLabel()
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
            SevenDayChartView(dailyTotals: dailyTotals, dailyGoal: 1000)
            SevenDayChartView(dailyTotals: dailyTotals, dailyGoal: 2000)
            SevenDayChartView(dailyTotals: dailyTotals, dailyGoal: 4000)
            
            SevenDayChartView(dailyTotals: [:], dailyGoal: 1000)
            SevenDayChartView(dailyTotals: [:], dailyGoal: 2000)
        }
        .padding()
    }
}
