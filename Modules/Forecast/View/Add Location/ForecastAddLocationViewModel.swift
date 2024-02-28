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
    enum Error: LocalizedError {
        case addFailed(any ForecastLocation)
        
        var errorDescription: String? {
            switch self {
            case .addFailed(let location):
                return "Failed to add the location \(location.name)"
            }
        }
    }
    
    class ViewModel: ObservableObject {
        private let locationStorage: LocationStoring
        
        @MainActor
        @Published var location: NamedLocation? {
            didSet {
                guard let location else { return }
                add(location: location)
            }
        }
        @MainActor
        @Published var error: Error?
        @MainActor
        @Published var dismissSearch: Bool = false
        
        init(locationStorage: LocationStoring) {
            self.locationStorage = locationStorage
        }
        
        func add(location: NamedLocation) {
            Task { @MainActor in
                do {
                    try await locationStorage.add(location: location)
                    dismissSearch = true
                } catch {
                    self.error = Error.addFailed(location)
                }
            }
        }
    }
}
