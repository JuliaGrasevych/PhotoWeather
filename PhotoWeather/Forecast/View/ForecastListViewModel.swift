//
//  ForecastListViewModel.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 05.02.2024.
//

import SwiftUI
import CoreLocation

extension ForecastList {
    @MainActor
    class ViewModel: ObservableObject {
        let fetcher: ForecastFetching
        let photoFetcher: PhotoStockFetching
        
        @Published var locations: [Location] = []
        
        init(
            fetcher: ForecastFetching,
            photoFetcher: PhotoStockFetching
        ) {
            self.fetcher = fetcher
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
