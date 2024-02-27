//
//  RootComponent.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 16.02.2024.
//

import Foundation
import SwiftUI
import NeedleFoundation
import Core

import PhotoStock
import PhotoStockDependency
import Forecast
import ForecastDependency
import Storage

final class RootComponent: BootstrapComponent {
    lazy var locationStore = LocationStorage(externalStore: storageComponent.userDefaultsStorage)
    
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
    
    public var locationManager: LocationManaging {
        shared {
            locationStore
        }
    }
    
    // MARK: - Child components
    var forecastComponent: ForecastComponent {
        ForecastComponent(parent: self)
    }
    
    var photoStockComponent: PhotoStockComponent {
        PhotoStockComponent(parent: self)
    }
    
    var storageComponent: StorageComponent {
        StorageComponent(parent: self)
    }
    
    /// Root view
    var rootView: some View {
        forecastComponent.view
    }
}
