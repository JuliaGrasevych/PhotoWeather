//
//  ForecastListViewModelOutput.swift
//  Forecast
//
//  Created by Julia Grasevych on 07.05.2024.
//

import Foundation

import ForecastDependency

@MainActor
class ForecastListViewModelOutput: ObservableObject {
    @Published var scrollToItem: String?
    @Published var allLocations: [any ForecastLocation] = [] {
        didSet {
            didSetAllLocations?(allLocations)
        }
    }
    
    var didSetAllLocations: (([any ForecastLocation]) -> ())?
}
