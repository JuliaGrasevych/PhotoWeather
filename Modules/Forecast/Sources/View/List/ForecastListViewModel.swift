//
//  ForecastListViewModel.swift
//  Forecast
//
//  Created by Julia Grasevych on 05.02.2024.
//

import SwiftUI
import NeedleFoundation
import Core

import PhotoStockDependency
import ForecastDependency

public protocol ForecastListDependency: Dependency {
    var locationStorage: LocationStoring { get }
    var locationProvider: LocationProviding { get }
}

class ForecastListViewModel: ForecastListViewModelProtocol {
    private let locationStorage: LocationStoring
    private let locationProvider: LocationProviding
    
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
    @Published var allLocations: [any ForecastLocation] = []
    
    init(
        locationStorage: LocationStoring,
        locationProvider: LocationProviding
    ) {
        self.locationStorage = locationStorage
        self.locationProvider = locationProvider
        
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
    func updateAllLocations() {
        allLocations = [currentLocation].compactMap { $0 } + locations
    }
}
