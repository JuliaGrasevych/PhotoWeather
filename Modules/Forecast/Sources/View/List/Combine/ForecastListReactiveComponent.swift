//
//  ForecastListReactiveComponent.swift
//  Forecast
//
//  Created by Julia Grasevych on 25.03.2024.
//

import Foundation
import SwiftUI

import NeedleFoundation

public class ForecastListReactiveComponent: Component<ForecastListReactiveDependency> {
    var viewModel: ForecastListViewModelReactive {
        ForecastListViewModelReactive(
            locationStorage: dependency.locationStorage,
            locationProvider: dependency.locationProvider
        )
    }
    
    @MainActor
    public var view: AnyView {
        AnyView(
            ForecastListView(
                viewModel: self.viewModel,
                itemBuilder: itemComponent,
                addLocationBuilder: addLocationComponent
            )
        )
    }
    
    var itemComponent: ForecastLocationItemBuilder {
        ForecastLocationItemReactiveComponent(parent: self)
    }
    
    var addLocationComponent: ForecastAddLocationViewBuilder {
        ForecastAddLocationReactiveComponent(parent: self)
    }
}
