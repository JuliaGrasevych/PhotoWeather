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
}

public struct Location {
    let name: String
    let location: ForecastLocation
}

extension ForecastLocationItem {
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
        private let location: Location
        
        private(set) lazy var locationName = location.name
        @Published private(set) var isFetching = false
        @Published private(set) var currentWeather: CurrentWeather = .default
        @Published private(set) var todayForecast: TodayForecast = .default
        @Published private(set) var hourlyForecast: [HourlyForecast] = [.default]
        @Published private(set) var dailyForecast: [DailyForecast] = [.default]
        @Published private(set) var imageURL: URL? = nil
        
        init(
            location: Location,
            weatherFetcher: ForecastFetching,
            photoFetcher: PhotoStockFetching
        ) {
            self.weatherFetcher = weatherFetcher
            self.photoFetcher = photoFetcher
            self.location = location
        }
        
        private nonisolated func fetchForecast(for location: ForecastLocation) async -> ForecastItem? {
            do {
                let weather = try await self.weatherFetcher.forecast(for: location)
                print(weather)
                return weather
            } catch {
                return nil
            }
        }
        
        private nonisolated func fetchImage(for location: ForecastLocation, forecast: ForecastItem?) async -> URL? {
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

extension ForecastLocationItem.ViewModel {
    @MainActor
    func onAppear() {
        Task { [weak self] in
            guard let self else { return }
            self.isFetching = true
            let forecast = await self.fetchForecast(for: location.location)
            self.currentWeather = ForecastLocationItem.CurrentWeather(model: forecast)
            self.todayForecast = Self.todayForecast(with: forecast)
            self.hourlyForecast = Self.hourlyForecast(with: forecast)
            self.dailyForecast = Self.dailyForecast(with: forecast)
            self.imageURL = await self.fetchImage(
                for: location.location,
                forecast: forecast
            )
            self.isFetching = false
        }
    }
    
    private static func todayForecast(with forecast: ForecastItem?) -> ForecastLocationItem.TodayForecast {
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
    
    private static func hourlyForecast(with forecast: ForecastItem?) -> [ForecastLocationItem.HourlyForecast] {
        guard let forecast, !forecast.hourly.weather.isEmpty else { return [.default] }
        let temperatureUnit = forecast.hourlyUnits.temperature
        return forecast.hourly.weather
            .map { item in
                ForecastLocationItem.HourlyForecast(
                    time: item.time.formatted(date: .omitted, time: .shortened),
                    temperature: item.temperature.formatted(.temperature) + temperatureUnit,
                    weatherIcon: item.formatted(.weatherIcon)
                )
        }
    }
    
    private static func dailyForecast(with forecast: ForecastItem?) -> [ForecastLocationItem.DailyForecast] {
        guard let forecast, !forecast.daily.weather.isEmpty else { return [.default] }
        let temperatureUnits = forecast.dailyUnits
        return forecast.daily.weather
            .map { item in
                ForecastLocationItem.DailyForecast(
                    date: item.time.formatted(Date.FormatStyle().day().month()),
                    temperatureMin: item.temperatureMin.formatted(.temperature) + temperatureUnits.temperatureMin,
                    temperatureMax: item.temperatureMax.formatted(.temperature) + temperatureUnits.temperatureMax,
                    weatherIcon: item.weatherCode.icon
                )
        }
    }
}

// MARK: - Defaults
extension ForecastLocationItem.CurrentWeather {
    private enum Defaults {
        static let temperature = "n/a"
        static let weatherIcon = "n/a"
        static let weatherDescription = "n/a"
    }
    
    static let `default` = ForecastLocationItem.CurrentWeather(
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

extension ForecastLocationItem.TodayForecast {
    static let `default` = ForecastLocationItem.TodayForecast(
        temperatureMin: "n/a",
        temperatureMax: "n/a"
    )
}

extension ForecastLocationItem.HourlyForecast {
    static let `default` = ForecastLocationItem.HourlyForecast(
        time: "12:00",
        temperature: "n/a",
        weatherIcon: "n/a"
    )
}

extension ForecastLocationItem.DailyForecast {
    static let `default` = ForecastLocationItem.DailyForecast(
        date: "01 Jan",
        temperatureMin: "n/a",
        temperatureMax: "n/a",
        weatherIcon: "n/a"
    )
}

extension ForecastLocationItem.HourlyForecast: Identifiable {
    var id: String {
        time
    }
}

extension ForecastLocationItem.DailyForecast: Identifiable {
    var id: String {
        date
    }
}
