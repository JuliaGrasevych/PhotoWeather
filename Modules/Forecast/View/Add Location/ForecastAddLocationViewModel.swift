//
//  ForecastAddLocationViewModel.swift
//  Forecast
//
//  Created by Julia Grasevych on 19.02.2024.
//

import Foundation
import SwiftUI
import Combine
import NeedleFoundation
import Core
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
    
    @MainActor
    class Output: ObservableObject {
        @Published var error: Error?
        @Published var dismissSearch: Bool = false
    }
    
    class ViewModel: ObservableObject, NestedObservedObjectOutputContainer {
        private let locationStorage: LocationStoring
        
        @MainActor
        @ObservedObject var output = ForecastAddLocationView.Output()
        @MainActor
        @Published var location: NamedLocation? {
            didSet {
                guard let location else { return }
                add(location: location)
            }
        }
        var nestedObservedObjectsSubscription: [AnyCancellable] = []
        
        init(locationStorage: LocationStoring) {
            self.locationStorage = locationStorage
        }
        
        func add(location: NamedLocation) {
            Task { @MainActor in
                do {
                    try await locationStorage.add(location: location)
                    output.dismissSearch = true
                } catch {
                    output.error = Error.addFailed(location)
                }
            }
        }
    }
}
