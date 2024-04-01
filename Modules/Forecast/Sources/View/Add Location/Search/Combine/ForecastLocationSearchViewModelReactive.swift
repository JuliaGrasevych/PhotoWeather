//
//  ForecastLocationSearchViewModelReactive.swift
//  Forecast
//
//  Created by Julia Grasevych on 26.03.2024.
//

import Foundation
import SwiftUI
import Combine

import NeedleFoundation
import Core
import ForecastDependency

public protocol ForecastLocationSearchReactiveDependency: Dependency {
    var locationFinder: LocationSearchingReactive { get }
}

class ForecastLocationSearchViewModelReactive: ForecastLocationSearchViewModelProtocol, NestedObservedObjectContainer {
    @MainActor
    @ObservedObject var input = ForecastLocationSearchViewModelInput()
    @MainActor
    var inputBinding: ObservedObject<ForecastLocationSearchViewModelInput>.Wrapper { $input }
    @MainActor
    @ObservedObject var output = ForecastLocationSearchViewModelOutput()
    @MainActor
    var outputBinding: ObservedObject<ForecastLocationSearchViewModelOutput>.Wrapper { $output }
    
    private let locationFinder: LocationSearchingReactive
    var nestedObservedObjectsSubscription: [AnyCancellable] = []
    
    init(locationFinder: LocationSearchingReactive) {
        self.locationFinder = locationFinder
        subscribeNestedObservedObjects()
        setupSearchQueryDebounce()
        handleSelection()
    }
    
    private func setupSearchQueryDebounce() {
        input.$text
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [locationFinder] output in
                Self.search(query: output, locationFinder: locationFinder)
            }
            .switchToLatest()
            .assign(to: &output.$searchResults)
    }
    
    private static func search(query: String, locationFinder: LocationSearchingReactive) -> AnyPublisher<[String], Never> {
        locationFinder.search(query: query)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    private func handleSelection() {
        input.$selection
            .map { [locationFinder] selection in
                guard let selection, !selection.isEmpty else { return Just<NamedLocation?>(nil).eraseToAnyPublisher() }
                return locationFinder.location(for: selection)
                    .mapOptional()
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .assign(to: &output.$location)
        
    }
}
