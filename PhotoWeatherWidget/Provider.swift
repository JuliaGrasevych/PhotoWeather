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

struct ForecastEntry: TimelineEntry {
    let date: Date
    let forecast: ForecastLocationItemWidgetViewModel
}

struct Provider: AppIntentTimelineProvider {
    typealias Entry = ForecastEntry
    typealias Intent = LocationIntent
    
    func snapshot(for configuration: LocationIntent, in context: Context) async -> ForecastEntry {
        return await forecastEntry(for: configuration.location)
    }
    
    func timeline(for configuration: LocationIntent, in context: Context) async -> Timeline<ForecastEntry> {
        let forecastEntry = await forecastEntry(for: configuration.location)
        let timeline = Timeline(entries: [forecastEntry], policy: .never)
        return timeline
    }
    
    func placeholder(in context: Context) -> ForecastEntry {
        ForecastEntry(date: .now, forecast: .placeholder)
    }
    
    private func forecastEntry(for location: any ForecastLocation) async -> ForecastEntry {
        let weatherFetcher = PhotoWeatherWidget.rootComponent.forecastComponent.weatherFetcherExport
        let photoFetcher = PhotoWeatherWidget.rootComponent.photoFetcher
        let currentDate = Date.now
        do {
            let forecast = try await weatherFetcher.forecast(for: location)
            let tags = location.photoTags + forecast.photoTags
            let image: UIImage?
            if let imagePhoto = try? await photoFetcher.photo(for: location, tags: tags),
               let imageData = try? Data(contentsOf: imagePhoto.url) {
                image = UIImage(data: imageData)
            } else {
                image = nil
            }
            return ForecastEntry(
                date: currentDate,
                forecast: .init(
                    location: location,
                    forecastItem: forecast,
                    image: image
                )
            )
        } catch {
            return ForecastEntry(
                date: currentDate,
                forecast: .placeholder
            )
        }
    }
}

extension ForecastLocationItemWidgetViewModel {
    init(location: any ForecastLocation, forecastItem: ForecastItem, image: UIImage?) {
        let currentWeather = forecastItem.current
        let currentWeatherModel = CurrentWeather(
            temperature: forecastItem.formattedTemperature,
            weatherIcon: currentWeather.formatted(.weatherIcon),
            weatherDescription: currentWeather.weatherCode.description
        )
        
        self.init(
            locationName: location.name,
            locationId: location.id,
            isUserLocation: location.isUserLocation,
            currentWeather: currentWeatherModel, 
            image: image
        )
    }
}
