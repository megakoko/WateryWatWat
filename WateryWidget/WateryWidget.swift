//
//  WateryWidget.swift
//  WateryWidget
//
//  Created by Andrey Chukavin on 22.12.2025.
//

import WidgetKit
import SwiftUI
import CoreData

// MARK: - Provider

struct Provider: TimelineProvider {
    private var volumeFormatter: VolumeFormatter {
        VolumeFormatter(unit: .liters)
    }

    func placeholder(in context: Context) -> WidgetHydrationEntry {
        let components = volumeFormatter.formattedComponents(from: 1500)
        return WidgetHydrationEntry(date: Date(), progress: 0.75, formattedValue: components.value, symbol: components.unit, unitPosition: components.unitPosition)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetHydrationEntry) -> ()) {
        let entry = fetchCurrentData()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = fetchCurrentData()

        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)

        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }

    private func fetchCurrentData() -> WidgetHydrationEntry {
        let container = PersistenceController.sharedWidget.container
        let context = container.viewContext

        let dailyGoal = UserDefaults(suiteName: Constants.appGroupIdentifier)?.object(forKey: Constants.dailyGoalKey) as? Int64 ?? Constants.defaultDailyGoalML

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let fetchRequest: NSFetchRequest<HydrationEntry> = HydrationEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)

        let todayTotal: Int64
        if let entries = try? context.fetch(fetchRequest) {
            todayTotal = entries.reduce(0) { $0 + $1.volume }
        } else {
            todayTotal = 0
        }

        let progress = Double(todayTotal) / Double(dailyGoal)
        let components = volumeFormatter.formattedComponents(from: todayTotal)

        return WidgetHydrationEntry(date: Date(), progress: progress, formattedValue: components.value, symbol: components.unit, unitPosition: components.unitPosition)
    }
}

// MARK: - WidgetHydrationEntry

struct WidgetHydrationEntry: TimelineEntry {
    let date: Date
    let progress: Double
    let formattedValue: String
    let symbol: String
    let unitPosition: UnitPosition
}

// MARK: - WateryWidgetEntryView

struct WateryWidgetEntryView : View {
    @Environment(\.widgetFamily) var family

    var entry: Provider.Entry

    private var homeScreenWidget: Bool {
        switch family {
        case .systemSmall:
            return true
        default:
            return false
        }
    }

    var body: some View {
        if homeScreenWidget {
            homeScreenView
        } else {
            lockScreenView
        }
    }

    private var homeScreenView: some View {
        CircularProgressView(progress: entry.progress, formattedValue: entry.formattedValue, symbol: entry.symbol, unitPosition: entry.unitPosition, font: .title.bold(), lineWidth: 14, color: .accent)
            .padding(4)
    }

    private var lockScreenView: some View {
        Gauge(value: entry.progress, label: {}) {
            Text(entry.formattedValue)
                .padding(.horizontal, 4)
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }
}

// MARK: - WateryWidget

struct WateryWidget: Widget {
    let kind: String = "WateryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WateryWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WateryWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.accessoryCircular, .systemSmall])
        .configurationDisplayName("Hydration")
        .description("Track your daily water intake")
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    WateryWidget()
} timeline: {
    WidgetHydrationEntry(date: .now, progress: 0.65, formattedValue: "1.3", symbol: "L", unitPosition: .afterValue)
    WidgetHydrationEntry(date: .now, progress: 0.9, formattedValue: "1.8", symbol: "L", unitPosition: .afterValue)
    WidgetHydrationEntry(date: .now, progress: 1.3, formattedValue: "2.6", symbol: "L", unitPosition: .afterValue)
}

#Preview(as: .accessoryCircular) {
    WateryWidget()
} timeline: {
    WidgetHydrationEntry(date: .now, progress: 0.65, formattedValue: "1.3", symbol: "L", unitPosition: .afterValue)
    WidgetHydrationEntry(date: .now, progress: 0.9, formattedValue: "1.8", symbol: "L", unitPosition: .afterValue)
    WidgetHydrationEntry(date: .now, progress: 1.3, formattedValue: "2.6", symbol: "L", unitPosition: .afterValue)
}
