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
    func view(location: any ForecastLocation) -> AnyView
}

public protocol ForecastLocationWidgetBuilder {
    func widgetView(location: any ForecastLocation) -> AnyView
}

public class ForecastLocationItemComponent: Component<ForecastLocationItemDependency>, ForecastLocationItemBuilder {
    func viewModel(location: any ForecastLocation) -> ForecastLocationItemViewModel {
        ForecastLocationItemViewModel(
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

extension ForecastLocationItemComponent: ForecastLocationWidgetBuilder {
    @MainActor
    public func widgetView(location: any ForecastLocation) -> AnyView {
        AnyView(
            ForecastLocationWidgetView(viewModel: self.viewModel(location: location))
        )
    }
}
