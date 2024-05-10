//
//  ForecastListViewModel.swift
//  Forecast
//
//  Created by Julia Grasevych on 05.02.2024.
//

import SwiftUI
import Combine
import NeedleFoundation
import Core

import PhotoStockDependency
import ForecastDependency

public protocol ForecastListDependency: Dependency {
    var locationStorage: LocationStoring { get }
    var locationProvider: LocationProviding { get }
}

class ForecastListViewModel: ForecastListViewModelProtocol, NestedObservedObjectOutputContainer {
    private let locationStorage: LocationStoring
    private let locationProvider: LocationProviding
    @MainActor
    private var deeplinkState: ForecastListDeeplinkState = .idle {
        didSet {
            handleDeeplinkIfNeeded()
        }
    }
    
    @MainActor 
    @Published var locations: [NamedLocation] = [] {
        didSet {
            updateAllLocations()
        }
    }
    @MainActor var currentLocation: (any ForecastLocation)? {
        didSet {
            updateAllLocations()
        }
    }
    
    @MainActor
    @ObservedObject var output = ForecastListViewModelOutput()
    var nestedObservedObjectsSubscription: [AnyCancellable] = []
    
    init(
        locationStorage: LocationStoring,
        locationProvider: LocationProviding
    ) {
        self.locationStorage = locationStorage
        self.locationProvider = locationProvider
        subscribeNestedObservedObjects()
        
        output.didSetAllLocations = { [weak self] _ in
            self?.handleDeeplinkIfNeeded()
        }
        
        Task { @MainActor in
            guard let locations = try? await locationStorage.locations() else {
                self.locations = []
                return
            }
            for await changes in locations {
                self.locations = changes
            }
        }
    }
    @MainActor
    func onAppear() {
        Task {
            do {
                if await locationProvider.isAuthorized() {
                    currentLocation = try await locationProvider.currentForecastLocation
                } else {
                    currentLocation = nil
                }
            } catch {
                currentLocation = nil
            }
        }
    }
    
    @MainActor
    private func updateAllLocations() {
        output.allLocations = [currentLocation].compactMap { $0 } + locations
    }
    
    @MainActor
    func handleDeeplinkIfNeeded() {
        guard case let .location(id) = deeplinkState else {
            return
        }
        output.scrollToItem = id
        deeplinkState = .idle
    }
    
    @MainActor
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
