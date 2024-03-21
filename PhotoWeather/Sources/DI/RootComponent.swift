//
//  RootComponent.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 16.02.2024.
//

import Foundation
import SwiftUI
import CoreLocation
import NeedleFoundation
import Core

import PhotoStock
import PhotoStockDependency
import Forecast
import ForecastDependency
import Storage

final class RootComponent: BootstrapComponent {
    struct Configuration {
        enum Storage {
            case userDefaults
            case swiftData
        }
        let storage: Storage
    }
    
    private let configuration: Configuration
    private lazy var locationStore: LocationStorage = {
        let externalStore: ExternalLocationStoring
        switch configuration.storage {
        case .userDefaults:
            externalStore = storageComponent.userDefaultsStorage
        case .swiftData:
            externalStore = storageComponent.swiftDataStorge
        }
        return LocationStorage(externalStore: externalStore)
    }()
    
    // MARK: - Child Dependencies
    public var networkService: NetworkServiceProtocol {
        shared {
            NetworkService()
        }
    }
    
    public var apiKeyProvider: FlickrAPIKeyProviding {
        shared {
            ConfigProvider()
        }
    }
    
    public var photoFetcher: PhotoStockFetching {
        shared {
            photoStockComponent.fetcher
        }
    }
    
    public var locationStorage: LocationStoring {
        shared {
            locationStore
        }
    }
    
    public var locationProvider: LocationProviding {
        shared {
            LocationProvider(locationManager: CLLocationManager())
        }
    }
    
    public var locationManager: LocationManaging {
        shared {
            locationStore
        }
    }
    
    // MARK: - Child components
    var forecastComponent: ForecastComponentProtocol {
        ForecastComponent(parent: self)
    }
    
    var photoStockComponent: PhotoStockComponent {
        PhotoStockComponent(parent: self)
    }
    
    var storageComponent: StorageComponent {
        StorageComponent(parent: self)
    }
    
    /// Root view
    @MainActor
    var rootView: some View {
        forecastComponent.view
    }
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
}

final class RootReactiveComponent: BootstrapComponent {
    struct Configuration {
        enum Storage {
            case userDefaults
            case swiftData
        }
        let storage: Storage
    }
    
    private let configuration: Configuration
    private lazy var locationStore: LocationStorage = {
        let externalStore: ExternalLocationStoring
        switch configuration.storage {
        case .userDefaults:
            externalStore = storageComponent.userDefaultsStorage
        case .swiftData:
            externalStore = storageComponent.swiftDataStorge
        }
        return LocationStorage(externalStore: externalStore)
    }()
    
    // MARK: - Child Dependencies
    public var networkService: NetworkServiceProtocol {
        shared {
            NetworkService()
        }
    }
    
    public var apiKeyProvider: FlickrAPIKeyProviding {
        shared {
            ConfigProvider()
        }
    }
    
    public var photoFetcher: PhotoStockFetchingReactive {
        shared {
            photoStockComponent.fetcherReactive
        }
    }
    
    public var locationStorage: LocationStoring {
        shared {
            locationStore
        }
    }
    
    public var locationProvider: LocationProviding {
        shared {
            LocationProvider(locationManager: CLLocationManager())
        }
    }
    
    public var locationManager: LocationManagingReactive {
        shared {
            locationStore
        }
    }
    
    // MARK: - Child components
    var forecastComponent: ForecastComponentProtocol {
        ForecastReactiveComponent(parent: self)
    }
    
    var photoStockComponent: PhotoStockComponent {
        PhotoStockComponent(parent: self)
    }
    
    var storageComponent: StorageComponent {
        StorageComponent(parent: self)
    }
    
    /// Root view
    @MainActor
    var rootView: some View {
        forecastComponent.view
    }
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
}
