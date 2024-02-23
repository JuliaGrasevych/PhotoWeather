//
//  ForecastLocationItemViewModel.swift
//  Forecast
//
//  Created by Julia Grasevych on 07.02.2024.
//

import SwiftUI
import CoreLocation
import NeedleFoundation
import Core

import PhotoStockDependency

public protocol ForecastLocationItemDependency: Dependency {
    var weatherFetcher: ForecastFetching { get }
    var photoFetcher: PhotoStockFetching { get }
    var locationManager: LocationManaging { get }
}

extension ForecastLocationItemView {
    struct CurrentWeather {
        let temperature: String
        let weatherIcon: String
        let weatherDescription: String
    }
    struct TodayForecast {
        let temperatureMin: String
        let temperatureMax: String
    }
    struct HourlyForecast {
        let time: String
        let temperature: String
        let weatherIcon: String
    }
    struct DailyForecast {
        let date: String
        let temperatureMin: String
        let temperatureMax: String
        let weatherIcon: String
    }
    
    class ViewModel: ObservableObject {
        private let weatherFetcher: ForecastFetching
        private let photoFetcher: PhotoStockFetching
        private let locationManager: LocationManaging
        private let location: NamedLocation
        
        // TODO: wrap this in 1 struct
        private(set) lazy var locationName = location.name
        @MainActor
        @Published private(set) var isFetching = false
        @MainActor
        @Published private(set) var currentWeather: CurrentWeather = .default
        @MainActor
        @Published private(set) var todayForecast: TodayForecast = .default
        @MainActor
        @Published private(set) var hourlyForecast: [HourlyForecast] = [.default]
        @MainActor
        @Published private(set) var dailyForecast: [DailyForecast] = [.default]
        @MainActor
        @Published private(set) var imageURL: URL? = nil
        
        init(
            location: NamedLocation,
            weatherFetcher: ForecastFetching,
            photoFetcher: PhotoStockFetching,
            locationManager: LocationManaging
        ) {
            self.weatherFetcher = weatherFetcher
            self.photoFetcher = photoFetcher
            self.locationManager = locationManager
            self.location = location
            onLoad()
        }
        
        private func fetchForecast(for location: ForecastLocation) async -> ForecastItem? {
            do {
                return try await self.weatherFetcher.forecast(for: location)
            } catch {
                return nil
            }
        }
        
        private func fetchImage(for location: ForecastLocation, forecast: ForecastItem?) async -> URL? {
            let tags = [
                try? location.season(for: Date.now, calendar: Calendar.current).tag,
                forecast?.current.weatherCode.description,
                forecast.map { $0.current.isDay ? "day" : "night" }
            ].compactMap { $0 }
            do {
                let url = try await self.photoFetcher.photoURL(
                    for: location,
                    tags: tags
                )
                return url
            } catch {
                return nil
            }
        }
    }
}

extension ForecastLocationItemView.ViewModel {
    func onLoad() {
        Task { @MainActor in
            isFetching = true
            let forecast = await fetchForecast(for: location.location)
            currentWeather = ForecastLocationItemView.CurrentWeather(model: forecast)
            todayForecast = Self.todayForecast(with: forecast)
            hourlyForecast = Self.hourlyForecast(with: forecast)
            dailyForecast = Self.dailyForecast(with: forecast)
            imageURL = await fetchImage(
                for: location.location,
                forecast: forecast
            )
            isFetching = false
        }
    }
    
    func deleteLocation() {
        Task {
            await locationManager.remove(location: location.id)
        }
    }
    
    private static func todayForecast(with forecast: ForecastItem?) -> ForecastLocationItemView.TodayForecast {
        guard let forecast,
              let today = forecast.daily
            .weather
            .first(where: { item in
                Calendar.current.isDateInToday(item.time)
            })
        else { return .default }

        let tempMin = today.temperatureMin.formatted(.temperature)
        + forecast.dailyUnits.temperatureMin
        let tempMax = today.temperatureMax.formatted(.temperature)
        + forecast.dailyUnits.temperatureMax
        
        return .init(
            temperatureMin: tempMin,
            temperatureMax: tempMax
        )
    }
    
    private static func hourlyForecast(with forecast: ForecastItem?) -> [ForecastLocationItemView.HourlyForecast] {
        guard let forecast, !forecast.hourly.weather.isEmpty else { return [.default] }
        let temperatureUnit = forecast.hourlyUnits.temperature
        return forecast.hourly.weather
            .map { item in
                ForecastLocationItemView.HourlyForecast(
                    time: item.time.formatted(date: .omitted, time: .shortened),
                    temperature: item.temperature.formatted(.temperature) + temperatureUnit,
                    weatherIcon: item.formatted(.weatherIcon)
                )
        }
    }
    
    private static func dailyForecast(with forecast: ForecastItem?) -> [ForecastLocationItemView.DailyForecast] {
        guard let forecast, !forecast.daily.weather.isEmpty else { return [.default] }
        let temperatureUnits = forecast.dailyUnits
        return forecast.daily.weather
            .map { item in
                ForecastLocationItemView.DailyForecast(
                    date: item.time.formatted(Date.FormatStyle().day().month()),
                    temperatureMin: item.temperatureMin.formatted(.temperature) + temperatureUnits.temperatureMin,
                    temperatureMax: item.temperatureMax.formatted(.temperature) + temperatureUnits.temperatureMax,
                    weatherIcon: item.weatherCode.icon
                )
        }
    }
}

// MARK: - Defaults
extension ForecastLocationItemView.CurrentWeather {
    private enum Defaults {
        static let temperature = "n/a"
        static let weatherIcon = "n/a"
        static let weatherDescription = "n/a"
    }
    
    static let `default` = ForecastLocationItemView.CurrentWeather(
        temperature: Defaults.temperature,
        weatherIcon: Defaults.weatherIcon,
        weatherDescription: Defaults.weatherDescription
    )
    
    init(model: ForecastItem?) {
        let currentWeather = model?.current
        let temperature = (currentWeather &&& model?.currentUnits)
            .map { weather, units in
                weather.temperature.formatted(.temperature)
                + units.temperature
        }
        self.init(
            temperature: temperature ?? Defaults.temperature,
            weatherIcon: currentWeather?.formatted(.weatherIcon) ?? Defaults.weatherIcon,
            weatherDescription: currentWeather?.weatherCode.description ?? Defaults.weatherDescription
        )
    }
}

extension ForecastLocationItemView.TodayForecast {
    static let `default` = ForecastLocationItemView.TodayForecast(
        temperatureMin: "n/a",
        temperatureMax: "n/a"
    )
}

extension ForecastLocationItemView.HourlyForecast {
    static let `default` = ForecastLocationItemView.HourlyForecast(
        time: "12:00",
        temperature: "n/a",
        weatherIcon: "n/a"
    )
}

extension ForecastLocationItemView.DailyForecast {
    static let `default` = ForecastLocationItemView.DailyForecast(
        date: "01 Jan",
        temperatureMin: "n/a",
        temperatureMax: "n/a",
        weatherIcon: "n/a"
    )
}

extension ForecastLocationItemView.HourlyForecast: Identifiable {
    var id: String {
        time
    }
}

extension ForecastLocationItemView.DailyForecast: Identifiable {
    var id: String {
        date
    }
}
