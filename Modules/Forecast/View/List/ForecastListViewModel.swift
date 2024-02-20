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

extension ForecastListView {
    class ViewModel: ObservableObject {
        private let weatherFetcher: ForecastFetching
        private let photoFetcher: PhotoStockFetching
        
        @MainActor
        @Published var locations: [Location] = []
        
        init(
            weatherFetcher: ForecastFetching,
            photoFetcher: PhotoStockFetching
        ) {
            self.weatherFetcher = weatherFetcher
            self.photoFetcher = photoFetcher
        }
        
        private func fetch() async -> [Location] {
            guard let locations = try? await CLGeocoder().geocodeAddressString("Kyiv, Ukraine"),
                  let loc = locations.first else {
                return []
            }
            return [Location(name: "loc.name", location: loc)]
        }
    }
}

extension ForecastListView.ViewModel {
    @MainActor 
    func onAppear() {
        Task {
            locations = await fetch()
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
