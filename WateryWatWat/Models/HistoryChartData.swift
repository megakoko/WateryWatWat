//
//  HistoryChartData.swift
//  WateryWatWat
//

import Foundation

struct HistoryChartData {
    static let empty = HistoryChartData(dailyTotals: [], goalPeriods: [])

    let dailyTotals: [DailyTotal]
    let goalPeriods: [GoalPeriod]
}
