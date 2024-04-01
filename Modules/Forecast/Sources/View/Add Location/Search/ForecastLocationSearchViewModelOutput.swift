//
//  ForecastLocationSearchViewModelOutput.swift
//  Forecast
//
//  Created by Julia Grasevych on 26.03.2024.
//

import Foundation

import ForecastDependency

@MainActor
class ForecastLocationSearchViewModelOutput: ObservableObject {
    @Published var searchResults: [String] = []
    @Published var location: NamedLocation?
}

@MainActor
class ForecastLocationSearchViewModelInput: ObservableObject {
    @Published var text: String = ""
    @Published var selection: String?
}
