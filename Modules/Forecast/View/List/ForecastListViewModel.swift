//
//  ForecastListViewModel.swift
//  Forecast
//
//  Created by Julia Grasevych on 05.02.2024.
//

import SwiftUI
import CoreLocation
import NeedleFoundation

import PhotoStockDependency

public protocol ForecastListDependency: Dependency {
    var weatherFetcher: ForecastFetching { get }
    var photoFetcher: PhotoStockFetching { get }
}

extension ForecastList {
    class ViewModel: ObservableObject {
        private let weatherFetcher: ForecastFetching
        private let photoFetcher: PhotoStockFetching
        
        @Published var locations: [Location] = []
        
        init(
            weatherFetcher: ForecastFetching,
            photoFetcher: PhotoStockFetching
        ) {
            self.weatherFetcher = weatherFetcher
            self.photoFetcher = photoFetcher
        }
        
        private nonisolated func fetch() async -> [Location] {
            guard let locations = try? await CLGeocoder().geocodeAddressString("Kyiv, Ukraine"),
                  let loc = locations.first else {
                return []
            }
            return [Location(name: "Kyiv", location: loc)]
        }
    }
}

extension ForecastList.ViewModel {
    @MainActor 
    func onAppear() {
        Task { [weak self] in
            guard let self else { return }
            self.locations = await self.fetch()
        }
    }
}

extension CLPlacemark: ForecastLocation {
    public var latitude: Float {
        Float(self.location?.coordinate.latitude ?? 0)
    }
    
    public var longitude: Float {
        Float(self.location?.coordinate.longitude ?? 0)
    }
    
    public var timeZoneIdentifier: String? {
        self.timeZone?.identifier
    }
}
