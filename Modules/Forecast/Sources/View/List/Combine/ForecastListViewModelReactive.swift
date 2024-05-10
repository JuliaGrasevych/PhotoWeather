//
//  ForecastListViewModelReactive.swift
//  Forecast
//
//  Created by Julia Grasevych on 25.03.2024.
//

import Foundation
import Combine
import SwiftUI

import NeedleFoundation
import Core

import PhotoStockDependency
import ForecastDependency

public protocol ForecastListReactiveDependency: Dependency {
    var locationStorage: LocationStoringReactive { get }
    var locationProvider: LocationProvidingReactive { get }
}

class ForecastListViewModelReactive: ForecastListViewModelProtocol, NestedObservedObjectOutputContainer {
    private let locationStorage: LocationStoringReactive
    private let locationProvider: LocationProvidingReactive
    @MainActor
    private var deeplinkState: ForecastListDeeplinkState = .idle {
        didSet {
            handleDeeplinkIfNeeded()
        }
    }
    
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
    
    @MainActor
    @Published var scrollToItem: String?
    
    @MainActor
    @ObservedObject var output = ForecastListViewModelOutput()
    var nestedObservedObjectsSubscription: [AnyCancellable] = []
    
    private var cancellables: [AnyCancellable] = []
    
    private let locationQueue = DispatchQueue(label: "com.julia.PhotoWeather.Forecast.locationQueue", qos: .userInteractive)
    
    init(
        locationStorage: LocationStoringReactive,
        locationProvider: LocationProvidingReactive
    ) {
        self.locationStorage = locationStorage
        self.locationProvider = locationProvider
        subscribeNestedObservedObjects()
        
        output.$allLocations
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.handleDeeplinkIfNeeded()
                }
            )
            .store(in: &cancellables)
        
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
        output.allLocations = [currentLocation].compactMap { $0 } + locations
    }
    
    func handleDeeplinkIfNeeded() {
        guard case let .location(id) = deeplinkState else {
            return
        }
        output.scrollToItem = id
        deeplinkState = .idle
    }
    
    func onOpenURL(_ url: URL) {
        guard url.scheme == URL.deeplinkScheme,
              url.host() == URL.locationDeeplinkHost
        else {
            return
        }
        let id = url.lastPathComponent
        guard !id.isEmpty else { return }
        deeplinkState = .location(id)
    }
}
