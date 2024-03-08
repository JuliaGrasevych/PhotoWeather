//
//  ForecastLocationItemViewModel.swift
//  Forecast
//
//  Created by Julia Grasevych on 07.02.2024.
//

import SwiftUI
import Combine
import CoreLocation
import NeedleFoundation
import Core

import PhotoStockDependency
import ForecastDependency

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
    
    enum Error: LocalizedError {
        case deleteFailed(any ForecastLocation)
        
        var errorDescription: String? {
            switch self {
            case .deleteFailed(let location):
                return "Failed to delete the location \(location.name)"
            }
        }
    }
    
    @MainActor
    class Output: ObservableObject {
        @Published var locationName: String = ""
        @Published var isUserLocation: Bool = false
        @Published var currentWeather: CurrentWeather = .default
        @Published var todayForecast: TodayForecast = .default
        @Published var hourlyForecast: [HourlyForecast] = [.default]
        @Published var dailyForecast: [DailyForecast] = [.default]
        @Published var imageURL: URL?
        @Published var imageAuthorTitle: String?
        @Published var error: Error?
    }
    
    class ViewModel: ObservableObject, NestedObservedObjectOutputContainer {
        private let weatherFetcher: ForecastFetching
        private let photoFetcher: PhotoStockFetching
        private let locationManager: LocationManaging
        private let location: any ForecastLocation
        
        @MainActor
        @ObservedObject var output: Output = Output()
        var nestedObservedObjectsSubscription: [AnyCancellable] = []
        
        init(
            location: any ForecastLocation,
            weatherFetcher: ForecastFetching,
            photoFetcher: PhotoStockFetching,
            locationManager: LocationManaging
        ) {
            self.weatherFetcher = weatherFetcher
            self.photoFetcher = photoFetcher
            self.locationManager = locationManager
            self.location = location
            subscribeNestedObservedObjects()
            
            Task { @MainActor in
                output.locationName = location.name
                output.isUserLocation = location.isUserLocation
            }
            onLoad()
        }
        
        private func fetchForecast(for location: any ForecastLocation) async -> ForecastItem? {
            do {
                return try await self.weatherFetcher.forecast(for: location)
            } catch {
                return nil
            }
        }
        
        private func fetchImage(for location: any ForecastLocation, forecast: ForecastItem?) async -> Photo? {
            let calendar = (try? Calendar.currentCalendar(for: location)) ?? Calendar.current
            let tags = [
                try? location.season(for: Date.now, calendar: calendar).tag,
                forecast?.current.weatherCode.description,
                forecast.map { $0.current.isDay ? "day" : "night" }
            ].compactMap { $0 }
            do {
                let photo = try await self.photoFetcher.photo(
                    for: location,
                    tags: tags
                )
                return photo
            } catch {
                // TODO: handle error and show default image
                return nil
            }
        }
    }
}

extension ForecastLocationItemView.ViewModel {
    func onLoad() {
        Task { @MainActor in
            let forecast = await fetchForecast(for: location)
            output.currentWeather = ForecastLocationItemView.CurrentWeather(model: forecast)
            output.todayForecast = Self.todayForecast(with: forecast, location: location)
            output.hourlyForecast = Self.hourlyForecast(with: forecast)
            output.dailyForecast = Self.dailyForecast(with: forecast)
            let photo = await fetchImage(
                for: location,
                forecast: forecast
            )
            output.imageURL = photo?.url
            output.imageAuthorTitle = photo?.author
        }
    }
    
    func deleteLocation() {
        Task { @MainActor in
            do {
                try await locationManager.remove(location: location.id)
            } catch {
                output.error = ForecastLocationItemView.Error.deleteFailed(location)
            }
        }
    }
    
    private static func todayForecast(with forecast: ForecastItem?, location: any ForecastLocation) -> ForecastLocationItemView.TodayForecast {
        let calendar = (try? Calendar.currentCalendar(for: location)) ?? Calendar.current
        guard let forecast,
              let today = forecast.daily
            .weather
            .first(where: { item in
                calendar.isDateInToday(item.time)
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
