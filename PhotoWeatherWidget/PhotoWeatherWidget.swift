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
    let urlSession: URLSession
//    static let rootComponent: RootComponent = RootComponent(configuration: .init(storage: .swiftData))
    static let rootComponent: RootComponent = RootComponent(configuration: .init(storage: .userDefaults))
    
    init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.urlCache = URLCache(
            memoryCapacity: 100 * 1024 * 1024, // 100 MB
            diskCapacity: 1024 * 1024 * 1024 // 1 GB
        )
        
        urlSession = URLSession(configuration: sessionConfig)
    }
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: LocationIntent.self,
            provider: Provider(urlSession: urlSession),
            content: { entry in
                PhotoWeatherWidgetEntryView(entry: entry, viewBuilder: Self.rootComponent.forecastComponent)
                    .containerBackground(.fill, for: .widget)
            }
        )
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName("Location Forecast")
        .description("Choose your location")
        .contentMarginsDisabled()
    }
}

extension ForecastLocationItemWidgetViewModel {
    static var placeholder: ForecastLocationItemWidgetViewModel = .init(
        locationName: "Kyiv",
        locationId: "1",
        isUserLocation: false,
        currentWeather: .init(
            temperature: "0°C",
            weatherSFSymbol: "questionmark.circle",
            weatherDescription: "n/a"
        ),
        image: nil
    )
}

#Preview(as: .systemSmall) {
    PhotoWeatherWidget()
} timeline: {
    ForecastEntry(date: .now, forecast: .placeholder)
}
