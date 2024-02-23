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
    var locationStorage: LocationStoring { get }
}

extension ForecastListView {
    class ViewModel: ObservableObject {
        private let locationStorage: LocationStoring
        
        @MainActor
        @Published var locations: [NamedLocation] = []
        
        init(
            locationStorage: LocationStoring
        ) {
            self.locationStorage = locationStorage
            
            Task { @MainActor in
                let locations = await locationStorage.locations()
                for await changes in locations {
                    self.locations = changes
                }
            }
        }
    }
}

extension CLPlacemark: ForecastLocation, @unchecked Sendable {
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
