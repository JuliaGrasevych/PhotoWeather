//
//  PhotoWeatherWidget.swift
//  PhotoWeatherWidget
//
//  Created by Julia Grasevych on 19.04.2024.
//

import WidgetKit
import SwiftUI
import ForecastDependency
// TODO: feed view with actual data
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct PhotoWeatherWidgetEntryView : View {
    var entry: Provider.Entry
    // not the best solution - rootComponent should be created once and stored.
    // can't implement this with struct for now
    private var rootComponent: RootComponent { RootComponent(configuration: .init(storage: .userDefaults)) }
    
    var body: some View {
        return rootComponent
            .forecastComponent
            .widgetView(location: PreviewLocation())
    }
}

struct PhotoWeatherWidget: Widget {
    let kind: String = "PhotoWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PhotoWeatherWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
fileprivate struct PreviewLocation: ForecastLocation {
    var id: String = UUID().uuidString
    var isUserLocation: Bool = false
    var name: String = "Kyiv"
    var latitude: Float = 0
    var longitude: Float = 0
    var timeZoneIdentifier: String? = nil
}

#Preview(as: .systemSmall) {
    PhotoWeatherWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}
