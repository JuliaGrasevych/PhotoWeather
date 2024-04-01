//
//  ForecastAddLocationViewModelReactive.swift
//  Forecast
//
//  Created by Julia Grasevych on 25.03.2024.
//

import Foundation
import SwiftUI
import Combine

import NeedleFoundation
import Core

import ForecastDependency

public protocol ForecastAddLocationReactiveDependency: Dependency {
    var locationStorage: LocationStoringReactive { get }
}

class ForecastAddLocationViewModelReactive: ForecastAddLocationViewModelProtocol, NestedObservedObjectOutputContainer {
    private let locationStorage: LocationStoringReactive
    
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
    private var cancellables: [AnyCancellable] = []
    
    init(locationStorage: LocationStoringReactive) {
        self.locationStorage = locationStorage
        subscribeNestedObservedObjects()
    }
    
    func add(location: NamedLocation) {
        locationStorage.add(location: location)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.output.dismissSearch = true
                    case .failure:
                        self?.output.error = ForecastAddLocationViewModelOutput.Error.addFailed(location)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}
