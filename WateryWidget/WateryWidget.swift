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
    func placeholder(in context: Context) -> WidgetHydrationEntry {
        WidgetHydrationEntry(date: Date(), progress: 0.75, formattedTotal: Int64(1500).formattedLiters())
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetHydrationEntry) -> ()) {
        let entry = fetchCurrentData()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = fetchCurrentData()
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func fetchCurrentData() -> WidgetHydrationEntry {
        let container = PersistenceController.shared.container
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
        let formattedTotal = todayTotal.formattedLiters()

        return WidgetHydrationEntry(date: Date(), progress: progress, formattedTotal: formattedTotal)
    }
}

// MARK: - WidgetHydrationEntry

struct WidgetHydrationEntry: TimelineEntry {
    let date: Date
    let progress: Double
    let formattedTotal: String
}

// MARK: - WateryWidgetEntryView

struct VariableSizeCircularStyle: GaugeStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { reader in
            ZStack {
                Circle()
                    .stroke(.primary.opacity(0.3), lineWidth: reader.size.width * 0.1)
                
                Circle()
                    .trim(to: configuration.value)
                    .stroke(.primary, style: .init(lineWidth: reader.size.width * 0.1, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                if let label = configuration.currentValueLabel {
                    label
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .padding(4)
    }
}

extension GaugeStyle where Self == VariableSizeCircularStyle {
    static var variableSizeCircular: VariableSizeCircularStyle { .init() }
}

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
            gauge(with: .variableSizeCircular)
                .foregroundStyle(Color.aquaBlue)
        } else {
            gauge(with: .accessoryCircularCapacity)
        }
    }
    
    private func gauge(with style: some GaugeStyle) -> some View {
        Gauge(value: entry.progress, label: {}) {
            Text(entry.formattedTotal)
                .padding(.horizontal, 4)
        }
        .gaugeStyle(style)
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
    WidgetHydrationEntry(date: .now, progress: 0.65, formattedTotal: "1,3L")
    WidgetHydrationEntry(date: .now, progress: 0.9, formattedTotal: "1,8L")
    WidgetHydrationEntry(date: .now, progress: 1.3, formattedTotal: "2,2L")
}

#Preview(as: .accessoryCircular) {
    WateryWidget()
} timeline: {
    WidgetHydrationEntry(date: .now, progress: 0.65, formattedTotal: "1,3L")
    WidgetHydrationEntry(date: .now, progress: 0.9, formattedTotal: "1,8L")
    WidgetHydrationEntry(date: .now, progress: 1.3, formattedTotal: "2,2L")
}
