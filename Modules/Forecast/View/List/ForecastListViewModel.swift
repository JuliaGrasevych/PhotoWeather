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
import ForecastDependency

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
