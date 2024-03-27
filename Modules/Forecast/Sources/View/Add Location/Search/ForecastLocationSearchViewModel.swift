//
//  ForecastLocationSearchViewModel.swift
//  Forecast
//
//  Created by Julia Grasevych on 19.02.2024.
//

import Foundation
import Combine
import SwiftUI
import NeedleFoundation
import Core
import ForecastDependency

public protocol ForecastLocationSearchDependency: Dependency {
    var locationFinder: LocationSearching { get }
}

class ForecastLocationSearchViewModel: ForecastLocationSearchViewModelProtocol, NestedObservedObjectContainer {
    @MainActor
    @ObservedObject var input = ForecastLocationSearchViewModelInput()
    @MainActor
    var inputBinding: ObservedObject<ForecastLocationSearchViewModelInput>.Wrapper { $input }
    @MainActor
    @ObservedObject var output = ForecastLocationSearchViewModelOutput()
    @MainActor
    var outputBinding: ObservedObject<ForecastLocationSearchViewModelOutput>.Wrapper { $output }
    
    private let locationFinder: LocationSearching
    private var searchSubscriptions: [AnyCancellable] = []
    private var selectionSubscription: AnyCancellable?
    var nestedObservedObjectsSubscription: [AnyCancellable] = []
    
    init(locationFinder: LocationSearching) {
        self.locationFinder = locationFinder
        subscribeNestedObservedObjects()
        setupSearchQueryDebounce()
        handleSelection()
    }
    
    private func setupSearchQueryDebounce() {
        input.$text
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] output in
                guard let self else { return }
                self.search(query: output)
            }
            .store(in: &searchSubscriptions)
    }
    
    private func search(query: String) {
        Task { @MainActor in
            do {
                output.searchResults = try await locationFinder.search(query: query)
            } catch {
                output.searchResults = []
            }
        }
    }
    
    private func handleSelection() {
        selectionSubscription = input.$selection
            .sink { [weak self] selection in
                guard let self else { return }
                Task { @MainActor in
                    guard let selection, !selection.isEmpty else { return }
                    self.output.location = try await self.locationFinder.location(for: selection)
                }
            }
    }
}
