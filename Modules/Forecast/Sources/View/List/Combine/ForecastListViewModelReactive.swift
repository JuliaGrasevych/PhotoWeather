//
//  ForecastListViewModelReactive.swift
//  Forecast
//
//  Created by Julia Grasevych on 25.03.2024.
//

import Foundation
import Combine

import NeedleFoundation
import Core

import PhotoStockDependency
import ForecastDependency

public protocol ForecastListReactiveDependency: Dependency {
    var locationStorage: LocationStoringReactive { get }
    var locationProvider: LocationProvidingReactive { get }
}

class ForecastListViewModelReactive: ForecastListViewModelProtocol {
    private let locationStorage: LocationStoringReactive
    private let locationProvider: LocationProvidingReactive
    
    @Published var locations: [NamedLocation] = [] {
        didSet {
            updateAllLocations()
        }
    }
    @Published var currentLocation: (any ForecastLocation)? {
        didSet {
            updateAllLocations()
        }
    }
    @Published var allLocations: [any ForecastLocation] = []
    
    private var cancellables: [AnyCancellable] = []
    
    private let locationQueue = DispatchQueue(label: "com.julia.PhotoWeather.Forecast.locationQueue", qos: .userInteractive)
    
    init(
        locationStorage: LocationStoringReactive,
        locationProvider: LocationProvidingReactive
    ) {
        self.locationStorage = locationStorage
        self.locationProvider = locationProvider
        
        locationStorage.locations()
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .sink(receiveValue: { [weak self] in
                self?.locations = $0
            })
            .store(in: &cancellables)
    }
    
    func onAppear() {
        locationProvider.isAuthorized()
            .subscribe(on: locationQueue)
            .receive(on: locationQueue)
            .flatMap { [weak self] isAuthorized in
                guard let self else {
                    return Just<(any ForecastLocation)?>(nil)
                        .eraseToAnyPublisher()
                }
                guard isAuthorized else {
                    return Just<(any ForecastLocation)?>(nil)
                        .eraseToAnyPublisher()
                }
                return locationProvider.currentForecastLocation
                    .mapOptional()
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.currentLocation = $0
            })
            .store(in: &cancellables)
    }
    
    func updateAllLocations() {
        allLocations = [currentLocation].compactMap { $0 } + locations
    }
    
    func onOpenURL(_ url: URL) {
        // TODO: implement
    }
}
