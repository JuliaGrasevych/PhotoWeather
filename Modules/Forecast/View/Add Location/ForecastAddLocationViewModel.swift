//
//  ForecastAddLocationViewModel.swift
//  Forecast
//
//  Created by Julia Grasevych on 19.02.2024.
//

import Foundation
import SwiftUI
import NeedleFoundation
import ForecastDependency

public protocol ForecastAddLocationDependency: Dependency {
    var locationStorage: LocationStoring { get }
}

extension ForecastAddLocationView {
    class ViewModel: ObservableObject {
        private let locationStorage: LocationStoring
        
        @MainActor
        @Published var location: NamedLocation? {
            didSet {
                guard let location else { return }
                add(location: location)
            }
        }
        
        init(locationStorage: LocationStoring) {
            self.locationStorage = locationStorage
        }
        
        func add(location: NamedLocation) {
            Task {
                await locationStorage.add(location: location)
            }
        }
    }
}
