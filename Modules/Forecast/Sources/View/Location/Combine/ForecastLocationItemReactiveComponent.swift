//
//  ForecastLocationItemReactiveComponent.swift
//  Forecast
//
//  Created by Julia Grasevych on 21.03.2024.
//

import Foundation
import SwiftUI
import NeedleFoundation

import ForecastDependency

public class ForecastLocationItemReactiveComponent: Component<ForecastLocationItemReactiveDependency>, ForecastLocationItemBuilder {
    func viewModel(location: any ForecastLocation) -> ForecastLocationItemViewModelReactive {
        ForecastLocationItemViewModelReactive(
            location: location,
            weatherFetcher: dependency.weatherFetcher,
            photoFetcher: dependency.photoFetcher,
            locationManager: dependency.locationManager
        )
    }
    
    @MainActor
    public func view(location: any ForecastLocation) -> AnyView {
        AnyView(
            ForecastLocationItemView(viewModel: self.viewModel(location: location))
        )
    }
}

extension ForecastLocationItemReactiveComponent: ForecastLocationWidgetBuilder {
    @MainActor
    public func widgetView(viewModel: ForecastLocationItemWidgetViewModel) -> AnyView {
        AnyView(
            ForecastLocationWidgetView(viewModel: viewModel)
        )
    }
}
