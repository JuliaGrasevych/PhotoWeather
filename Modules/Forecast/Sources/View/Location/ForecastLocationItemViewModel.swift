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

class ForecastLocationItemViewModel: ForecastLocationItemViewModelProtocol, NestedObservedObjectOutputContainer {
    private let weatherFetcher: ForecastFetching
    private let photoFetcher: PhotoStockFetching
    private let locationManager: LocationManaging
    private let location: any ForecastLocation
    
    @MainActor
    @ObservedObject var output = ForecastLocationItemViewModelOutput()
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
    
    private func fetchImage(for location: any ForecastLocation, forecast: ForecastItem?) async -> LocationPhoto {
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
            return .stockPhoto(photo)
        } catch {
            return .default
        }
    }
}

extension ForecastLocationItemViewModel {
    func onLoad() {
        Task { @MainActor in
            await refresh()
        }
    }
    
    @MainActor
    func refresh() async {
        let forecast = await fetchForecast(for: location)
        output.currentWeather = ForecastLocationItemViewModelOutput.CurrentWeather(model: forecast)
        output.todayForecast = Self.todayForecast(with: forecast, location: location)
        output.hourlyForecast = Self.hourlyForecast(with: forecast)
        output.dailyForecast = Self.dailyForecast(with: forecast)
        let photo = await fetchImage(
            for: location,
            forecast: forecast
        )
        output.image = photo
        if case .stockPhoto(let stockPhoto) = photo {
            output.imageAuthorTitle = stockPhoto.author
        }
    }
    
    func deleteLocation() {
        Task { @MainActor in
            do {
                try await locationManager.remove(location: location.id)
            } catch {
                output.error = ForecastLocationItemViewModelOutput.Error.deleteFailed(location)
            }
        }
    }
}

// MARK: - Defaults
extension ForecastLocationItemViewModelOutput.CurrentWeather {
    private enum Defaults {
        static let temperature = "n/a"
        static let weatherIcon = "n/a"
        static let weatherDescription = "n/a"
    }
    
    static let `default` = ForecastLocationItemViewModelOutput.CurrentWeather(
        temperature: Defaults.temperature,
        weatherIcon: Defaults.weatherIcon,
        weatherDescription: Defaults.weatherDescription
    )
    
    init(model: ForecastItem?) {
        let currentWeather = model?.current
        self.init(
            temperature: model?.formattedTemperature ?? Defaults.temperature,
            weatherIcon: currentWeather?.formatted(.weatherIcon) ?? Defaults.weatherIcon,
            weatherDescription: currentWeather?.weatherCode.description ?? Defaults.weatherDescription
        )
    }
}

extension ForecastLocationItemViewModelOutput.TodayForecast {
    static let `default` = ForecastLocationItemViewModelOutput.TodayForecast(
        temperatureMin: "n/a",
        temperatureMax: "n/a"
    )
}

extension ForecastLocationItemViewModelOutput.HourlyForecast {
    static let `default` = ForecastLocationItemViewModelOutput.HourlyForecast(
        time: "12:00",
        temperature: "n/a",
        weatherIcon: "n/a"
    )
}

extension ForecastLocationItemViewModelOutput.DailyForecast {
    static let `default` = ForecastLocationItemViewModelOutput.DailyForecast(
        date: "01 Jan",
        temperatureMin: "n/a",
        temperatureMax: "n/a",
        weatherIcon: "n/a"
    )
}

extension ForecastLocationItemViewModelOutput.HourlyForecast: Identifiable {
    var id: String {
        time
    }
}

extension ForecastLocationItemViewModelOutput.DailyForecast: Identifiable {
    var id: String {
        date
    }
}
