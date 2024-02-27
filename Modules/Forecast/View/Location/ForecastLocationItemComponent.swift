//
//  ForecastLocationItemComponent.swift
//  Forecast
//
//  Created by Julia Grasevych on 16.02.2024.
//

import Foundation
import SwiftUI
import NeedleFoundation
import ForecastDependency

public protocol ForecastLocationItemBuilder {
    func view(location: NamedLocation) -> AnyView
}

public class ForecastLocationItemComponent: Component<ForecastLocationItemDependency>, ForecastLocationItemBuilder {
    func viewModel(location: NamedLocation) -> ForecastLocationItemView.ViewModel {
        ForecastLocationItemView.ViewModel(
            location: location,
            weatherFetcher: dependency.weatherFetcher,
            photoFetcher: dependency.photoFetcher,
            locationManager: dependency.locationManager
        )
    }
    
    public func view(location: NamedLocation) -> AnyView {
        AnyView(
            ForecastLocationItemView(viewModel: self.viewModel(location: location))
        )
    }
}
