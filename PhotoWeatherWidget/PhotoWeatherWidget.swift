//
//  PhotoWeatherWidget.swift
//  PhotoWeatherWidget
//
//  Created by Julia Grasevych on 19.04.2024.
//

import WidgetKit
import AppIntents
import SwiftUI
import ForecastDependency
import Core
import Forecast

struct PhotoWeatherWidgetEntryView : View {
    let entry: Provider.Entry
    private let viewBuilder: ForecastComponentProtocol
    
    init(entry: Provider.Entry, viewBuilder: ForecastComponentProtocol) {
        self.entry = entry
        self.viewBuilder = viewBuilder
    }
    
    var body: some View {
        viewBuilder.widgetView(viewModel: entry.forecast)
    }
}

struct PhotoWeatherWidget: Widget {
    let kind: String = "PhotoWeatherWidget"
    
    static let rootComponent: RootComponent = RootComponent(configuration: .init(storage: .swiftData))
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: LocationIntent.self,
            provider: Provider(),
            content: { entry in
                PhotoWeatherWidgetEntryView(entry: entry, viewBuilder: Self.rootComponent.forecastComponent)
                    .containerBackground(.fill.tertiary, for: .widget)
            })
        .configurationDisplayName("Location Forecast")
        .description("Choose your location")
    }
}

extension ForecastLocationItemWidgetViewModel {
    static var placeholder: ForecastLocationItemWidgetViewModel = .init(
        locationName: "Kyiv",
        isUserLocation: false,
        currentWeather: .init(
            temperature: "0°C",
            weatherIcon: "n/a",
            weatherDescription: "n/a"
        ),
        image: nil
    )
}

#Preview(as: .systemSmall) {
    PhotoWeatherWidget()
} timeline: {
    SimpleEntry(date: .now, forecast: .placeholder)
}
