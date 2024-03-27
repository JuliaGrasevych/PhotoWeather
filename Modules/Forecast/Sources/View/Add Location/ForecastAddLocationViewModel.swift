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

class ForecastAddLocationViewModel: ForecastAddLocationViewModelProtocol, NestedObservedObjectOutputContainer {
    private let locationStorage: LocationStoring
    
    @MainActor
    @ObservedObject var output = ForecastAddLocationViewModelOutput()
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
        subscribeNestedObservedObjects()
    }
    
    func add(location: NamedLocation) {
        Task { @MainActor in
            do {
                try await locationStorage.add(location: location)
                output.dismissSearch = true
            } catch {
                output.error = ForecastAddLocationViewModelOutput.Error.addFailed(location)
            }
        }
    }
}
