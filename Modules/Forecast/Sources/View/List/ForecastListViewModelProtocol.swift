//
//  ForecastListViewModelProtocol.swift
//  Forecast
//
//  Created by Julia Grasevych on 25.03.2024.
//

import Foundation

import ForecastDependency

protocol ForecastListViewModelProtocol: ObservableObject {
    var allLocations: [any ForecastLocation] { get }
    func onAppear()
}
