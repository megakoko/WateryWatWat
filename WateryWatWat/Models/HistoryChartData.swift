//
//  HistoryChartData.swift
//  WateryWatWat
//

import Foundation

struct HistoryChartData {
    let dailyTotals: [DailyTotal]
    let goalPeriods: [GoalPeriod]

    static let empty = HistoryChartData(dailyTotals: [], goalPeriods: [])
}
