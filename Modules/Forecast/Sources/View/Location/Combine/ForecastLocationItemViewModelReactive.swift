//
//  ForecastLocationItemViewModelReactive.swift
//  Forecast
//
//  Created by Julia Grasevych on 19.03.2024.
//

import Foundation
import SwiftUI
import Combine
import NeedleFoundation
import Core

import ForecastDependency
import PhotoStockDependency

public protocol ForecastLocationItemReactiveDependency: Dependency {
    var weatherFetcher: ForecastFetchingReactive { get }
    var photoFetcher: PhotoStockFetchingReactive { get }
    var locationManager: LocationManagingReactive { get }
}

class ForecastLocationItemViewModelReactive: ForecastLocationItemViewModelProtocol, NestedObservedObjectOutputContainer {
    private let weatherFetcher: ForecastFetchingReactive
    private let photoFetcher: PhotoStockFetchingReactive
    private let locationManager: LocationManagingReactive
    private let location: any ForecastLocation
    
    @MainActor
    @ObservedObject var output = ForecastLocationItemViewModelOutput()
    var nestedObservedObjectsSubscription: [AnyCancellable] = []
    private var cancellables: [AnyCancellable] = []
    
    private let forecastQueue = DispatchQueue(label: "com.julia.PhotoWeather.Forecast.forecastQueue", qos: .userInteractive)
    private let forecastPhotoQueue = DispatchQueue(label: "com.julia.PhotoWeather.Forecast.forecastPhotoQueue", qos: .userInteractive)
    
    init(
        location: any ForecastLocation,
        weatherFetcher: ForecastFetchingReactive,
        photoFetcher: PhotoStockFetchingReactive,
        locationManager: LocationManagingReactive
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
    
    private func fetchImage(for location: any ForecastLocation, forecast: ForecastItem?) -> AnyPublisher<LocationPhoto, Never> {
        let calendar = (try? Calendar.currentCalendar(for: location)) ?? Calendar.current
        let tags = [
            try? location.season(for: Date.now, calendar: calendar).tag,
            forecast?.current.weatherCode.description,
            forecast.map { $0.current.isDay ? "day" : "night" }
        ].compactMap { $0 }
        
        return photoFetcher.photo(
            for: location,
            tags: tags
        )
        .subscribe(on: forecastPhotoQueue)
        .receive(on: forecastPhotoQueue)
        .map(LocationPhoto.stockPhoto)
        .replaceError(with: LocationPhoto.default)
        .eraseToAnyPublisher()
    }
}

extension ForecastLocationItemViewModelReactive {
    func onLoad() {
        let forecastSubject = PassthroughSubject<ForecastItem?, Never>()
        let forecast = weatherFetcher.forecast(for: location)
            .subscribe(on: forecastQueue)
            .mapOptional()
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .multicast(subject: forecastSubject)
        
        forecast
            .map(ForecastLocationItemViewModelOutput.CurrentWeather.init)
            .assign(to: &output.$currentWeather)
        forecast
            .map { [weak self] location in
                guard let self else { return .default }
                return Self.todayForecast(with: location, location: self.location)
            }
            .assign(to: &output.$todayForecast)
        forecast
            .map { Self.hourlyForecast(with: $0) }
            .assign(to: &output.$hourlyForecast)
        forecast
            .map { Self.dailyForecast(with: $0) }
            .assign(to: &output.$dailyForecast)
        
        forecast
            .map { [weak self] item in
                guard let self else {
                    return Empty<LocationPhoto, Never>()
                        .eraseToAnyPublisher()
                }
                return self.fetchImage(
                    for: self.location,
                    forecast: item)
            }
            .switchToLatest()
            .mapOptional()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] photo in
                if case .stockPhoto(let stockPhoto) = photo {
                    self?.output.imageAuthorTitle = stockPhoto.author
                }
            })
            .assign(to: &output.$image)
        
        forecast.connect()
            .store(in: &cancellables)
    }
    
    func deleteLocation() {
        locationManager.remove(location: location.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure:
                        guard let self else { return }
                        self.output.error = ForecastLocationItemViewModelOutput.Error.deleteFailed(self.location)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}
