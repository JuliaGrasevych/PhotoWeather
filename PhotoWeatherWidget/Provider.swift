//
//  Provider.swift
//  PhotoWeatherWidget
//
//  Created by Julia Grasevych on 26.04.2024.
//

import Foundation
import WidgetKit
import ForecastDependency
import Forecast
import Core

struct SimpleEntry: TimelineEntry {
    let date: Date
    let forecast: ForecastLocationItemWidgetViewModel
}

// TODO: feed view with actual data
// TODO: configuration intent? to set city?
struct Provider: AppIntentTimelineProvider {
    typealias Entry = SimpleEntry
    typealias Intent = LocationIntent
    
    func snapshot(for configuration: LocationIntent, in context: Context) async -> SimpleEntry {
        let weatherFetcher = PhotoWeatherWidget.rootComponent.forecastComponent.weatherFetcherExport
        do {
            let forecast = try await weatherFetcher.forecast(for: configuration.location)
            return SimpleEntry(date: Date(), forecast: .init(location: configuration.location, forecastItem: forecast))
        } catch {
            return SimpleEntry(date: Date(), forecast: .placeholder)
        }
    }
    
    // TODO: image can't be downloaded asynchronously on view - load here
    func timeline(for configuration: LocationIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let weatherFetcher = PhotoWeatherWidget.rootComponent.forecastComponent.weatherFetcherExport
        let currentDate = Date.now
        do {
            let forecast = try await weatherFetcher.forecast(for: configuration.location)
            let entry = SimpleEntry(date: currentDate, forecast: .init(location: configuration.location, forecastItem: forecast))
            let timeline = Timeline(entries: [entry], policy: .never)
            return timeline
        } catch {
            let entry = SimpleEntry(date: currentDate, forecast: .placeholder)
            let timeline = Timeline(entries: [entry], policy: .never)
            return timeline
        }
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), forecast: .placeholder)
    }
}

extension ForecastLocationItemWidgetViewModel {
    init(location: any ForecastLocation, forecastItem: ForecastItem) {
        let currentWeather = forecastItem.current
        // TODO: the same code is in Forecast module - move to common place
        let temperature = currentWeather.temperature.formatted(.temperature) + forecastItem.currentUnits.temperature
        let currentWeatherModel = CurrentWeather(
            temperature: temperature,
            weatherIcon: currentWeather.formatted(.weatherIcon),
            weatherDescription: currentWeather.weatherCode.description
        )
        
        self.init(
            locationName: location.name,
            isUserLocation: location.isUserLocation,
            currentWeather: currentWeatherModel
        )
    }
}

// TODO: add font resource to widget target (Tuist) and info.plist
// TODO: add default image resource
