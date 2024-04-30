//
//  Provider.swift
//  PhotoWeatherWidget
//
//  Created by Julia Grasevych on 26.04.2024.
//

import Foundation
import UIKit
import WidgetKit
import ForecastDependency
import Forecast
import Core

struct SimpleEntry: TimelineEntry {
    let date: Date
    let forecast: ForecastLocationItemWidgetViewModel
}

struct Provider: AppIntentTimelineProvider {
    typealias Entry = SimpleEntry
    typealias Intent = LocationIntent
    
    func snapshot(for configuration: LocationIntent, in context: Context) async -> SimpleEntry {
        let weatherFetcher = PhotoWeatherWidget.rootComponent.forecastComponent.weatherFetcherExport
        do {
            let forecast = try await weatherFetcher.forecast(for: configuration.location)
            return SimpleEntry(
                date: Date(),
                forecast: .init(
                    location: configuration.location,
                    forecastItem: forecast,
                    image: nil
                )
            )
        } catch {
            return SimpleEntry(date: Date(), forecast: .placeholder)
        }
    }
    
    func timeline(for configuration: LocationIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let weatherFetcher = PhotoWeatherWidget.rootComponent.forecastComponent.weatherFetcherExport
        let photoFetcher = PhotoWeatherWidget.rootComponent.photoFetcher
        let currentDate = Date.now
        let location = configuration.location
        do {
            let forecast = try await weatherFetcher.forecast(for: configuration.location)
            // TODO: move to common place - the same in forecast module
            let calendar = (try? Calendar.currentCalendar(for: location)) ?? Calendar.current
            let tags = [
                try? location.season(for: Date.now, calendar: calendar).tag,
                forecast.current.weatherCode.description,
                forecast.current.isDay ? "day" : "night"
            ].compactMap { $0 }
            let image: UIImage?
            if let imagePhoto = try? await photoFetcher.photo(for: location, tags: tags),
               let imageData = try? Data(contentsOf: imagePhoto.url) {
                image = UIImage(data: imageData)
            } else {
                image = nil
            }
            let entry = SimpleEntry(
                date: currentDate,
                forecast: .init(
                    location: location,
                    forecastItem: forecast,
                    image: image
                )
            )
            let timeline = Timeline(entries: [entry], policy: .never)
            return timeline
        } catch {
            let entry = SimpleEntry(
                date: currentDate,
                forecast: .placeholder
            )
            let timeline = Timeline(entries: [entry], policy: .never)
            return timeline
        }
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), forecast: .placeholder)
    }
}

extension ForecastLocationItemWidgetViewModel {
    init(location: any ForecastLocation, forecastItem: ForecastItem, image: UIImage?) {
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
            currentWeather: currentWeatherModel, 
            image: image
        )
    }
}
