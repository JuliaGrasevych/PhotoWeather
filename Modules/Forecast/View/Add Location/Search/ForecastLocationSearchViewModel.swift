//
//  ForecastLocationSearchViewModel.swift
//  Forecast
//
//  Created by Julia Grasevych on 19.02.2024.
//

import Foundation
import Combine
import NeedleFoundation

public protocol ForecastLocationSearchDependency: Dependency {
    var locationFinder: LocationSearching { get }
}

extension ForecastLocationSearchView {
    class ViewModel: ObservableObject {
        @Published var text: String = ""
        @MainActor
        @Published var searchResults: [String] = []
        
        private let locationFinder: LocationSearching
        private var subscriptions: [AnyCancellable] = []
        
        init(locationFinder: LocationSearching) {
            self.locationFinder = locationFinder
            setupSearchQueryDebounce()
        }
        
        private func setupSearchQueryDebounce() {
            $text
                .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink { [weak self] output in
                    guard let self else { return }
                    Task {
                        await self.search(query: output)
                    }
                }
                .store(in: &subscriptions)
        }
        
        @MainActor
        private func search(query: String) {
            Task {
                do {
                    searchResults = try await locationFinder.search(query: query)
                } catch {
                    searchResults = []
                }
            }
        }
    }
}
