//
//  ForecastAddLocationViewModelOutput.swift
//  Forecast
//
//  Created by Julia Grasevych on 25.03.2024.
//

import Foundation

import ForecastDependency

@MainActor
class ForecastAddLocationViewModelOutput: ObservableObject {
    @Published var error: Error?
    @Published var dismissSearch: Bool = false
}

extension ForecastAddLocationViewModelOutput {
    enum Error: LocalizedError {
        case addFailed(any ForecastLocation)
        
        var errorDescription: String? {
            switch self {
            case .addFailed(let location):
                return "Failed to add the location \(location.name)"
            }
        }
    }
}
