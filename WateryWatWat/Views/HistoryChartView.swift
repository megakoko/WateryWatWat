import Charts
import SwiftUI

// MARK: - HistoryChartView

struct HistoryChartView: View {
    @State private var selectedTotal: DailyTotal? = nil
    @State private var selectedX: CGFloat? = nil
    @State private var tooltipWidth: CGFloat = 0

    let dailyTotals: [DailyTotal]
    let goalPeriods: [GoalPeriod]
    let periodDays: Int
    let onTogglePeriod: () -> Void

    private let calendar = Calendar.current
    private let volumeFormatter = VolumeFormatter(unit: .liters, minimumFractionDigits: 1)

    private var xAxisValues: [Date] {
        let today = calendar.startOfDay(for: Date())
        return [
            calendar.date(byAdding: .day, value: -28, to: today)!,
            calendar.date(byAdding: .day, value: -21, to: today)!,
            calendar.date(byAdding: .day, value: -14, to: today)!,
            calendar.date(byAdding: .day, value: -7, to: today)!,
        ]
    }

    var body: some View {
        Chart {
            ForEach(dailyTotals, id: \.date) { total in
                BarMark(
                    x: .value("Day", total.date, unit: .day),
                    y: .value("Volume", total.volume)
                )
                .foregroundStyle(barColor(for: total))
                .cornerRadius(periodDays == 7 ? 8 : 2)
            }

            ForEach(goalPeriods, id: \.start) { period in
                RuleMark(xStart: .value("Start", period.start), xEnd: .value("End", period.end.nextDay), y: .value("Goal", period.value))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [10, 5]))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
        }
        .chartXAxis {
            if periodDays == 7 {
                AxisMarks(values: .stride(by: .day)) { _ in
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
            if let latestGoal = goalPeriods.last {
                AxisMarks(values: [Double(latestGoal.value)]) { value in
                    AxisValueLabel {
                        if let goalValue = value.as(Double.self) {
                            Text(volumeFormatter.string(from: Int64(goalValue)))
                                .textCase(.uppercase)
                        }
                    }
                }
            }
        }
        .chartOverlay { proxy in
            scrubOverlay(proxy: proxy)
        }
        .frame(height: 100)
        .overlay(alignment: .top) {
            tooltipView
        }
    }

    @ViewBuilder
    private var tooltipView: some View {
        if let total = selectedTotal, let x = selectedX {
            Text(volumeFormatter.string(from: total.volume))
                .font(.caption.bold().monospacedDigit())
                .textCase(.uppercase)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
                .fixedSize()
                .background(GeometryReader { geo in
                    Color.clear.onAppear { tooltipWidth = geo.size.width }
                        .onChange(of: geo.size.width) { tooltipWidth = $1 }
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(x: x - tooltipWidth / 2)
        }
    }

    private func scrubOverlay(proxy: ChartProxy) -> some View {
        Rectangle()
            .fill(.clear)
            .contentShape(Rectangle())
            .gesture(
                LongPressGesture(minimumDuration: 0.3)
                    .sequenced(before: DragGesture(minimumDistance: 0))
                    .onChanged { value in
                        if case .second(true, let drag) = value, let drag {
                            updateSelection(at: drag.location, proxy: proxy)
                        }
                    }
                    .onEnded { _ in
                        selectedTotal = nil
                        selectedX = nil
                    }
            )
    }

    private func barColor(for total: DailyTotal) -> Color {
        guard selectedTotal != nil else {
            return Color.accentColor
        }

        return calendar.isDate(total.date, inSameDayAs: selectedTotal!.date) ? Color.accentColor : Color.accentColor.opacity(0.3)
    }

    private func updateSelection(at location: CGPoint, proxy: ChartProxy) {
        guard let date = proxy.value(atX: location.x, as: Date.self) else {
            return
        }

        let match = dailyTotals.first { calendar.isDate($0.date, inSameDayAs: date) }
        selectedTotal = match
        selectedX = location.x
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

extension Date {
    fileprivate var nextDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
}
