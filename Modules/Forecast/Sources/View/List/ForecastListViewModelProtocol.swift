//
//  ForecastListViewModelProtocol.swift
//  Forecast
//
//  Created by Julia Grasevych on 25.03.2024.
//

import Foundation

protocol ForecastListViewModelProtocol: ObservableObject {
    var output: ForecastListViewModelOutput { get }

    func onAppear()
    func onOpenURL(_ url: URL)
}

enum ForecastListDeeplinkState {
    case idle
    case location(String)
}
