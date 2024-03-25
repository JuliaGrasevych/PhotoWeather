//
//  ForecastAddLocationViewModelProtocol.swift
//  Forecast
//
//  Created by Julia Grasevych on 25.03.2024.
//

import Foundation

import ForecastDependency

protocol ForecastAddLocationViewModelProtocol: ObservableObject {
    var output: ForecastAddLocationViewModelOutput { get }
    var location: NamedLocation? { get set }
}
