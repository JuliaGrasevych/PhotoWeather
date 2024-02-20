//
//  ForecastLocationItemComponent.swift
//  Forecast
//
//  Created by Julia Grasevych on 16.02.2024.
//

import Foundation
import SwiftUI
import NeedleFoundation

public protocol ForecastLocationItemBuilder {
    func view(location: Location) -> AnyView
}

public class ForecastLocationItemComponent: Component<ForecastLocationItemDependency>, ForecastLocationItemBuilder {
    func viewModel(location: Location) -> ForecastLocationItemView.ViewModel {
        ForecastLocationItemView.ViewModel(
            location: location,
            weatherFetcher: dependency.weatherFetcher,
            photoFetcher: dependency.photoFetcher
        )
    }
    
    public func view(location: Location) -> AnyView {
        AnyView(
            ForecastLocationItemView(viewModel: self.viewModel(location: location))
        )
    }
}
