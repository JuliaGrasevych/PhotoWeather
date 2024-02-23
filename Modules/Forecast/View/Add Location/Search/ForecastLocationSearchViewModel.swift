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

public protocol ForecastLocationSearchDependency: Dependency {
    var locationFinder: LocationSearching { get }
}

extension ForecastLocationSearchView {
    class ViewModel: ObservableObject {
        @MainActor
        @Published var text: String = ""
        @MainActor
        @Published var searchResults: [String] = []
        @MainActor
        @Published var selection: String? {
            didSet {
                handleSelection()
            }
        }
        @MainActor
        @Published var dismiss: Bool = false
        @MainActor
        @Published var location: NamedLocation?
        
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
                    self.search(query: output)
                }
                .store(in: &subscriptions)
        }
        
        private func search(query: String) {
            Task { @MainActor in
                do {
                    searchResults = try await locationFinder.search(query: query)
                } catch {
                    searchResults = []
                }
            }
        }
        
        private func handleSelection() {
            Task { @MainActor in
                guard let selection, !selection.isEmpty else { return }
                location = try await locationFinder.location(for: selection)
                dismiss = true
            }
        }
    }
}
