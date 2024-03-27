//
//  ForecastAddLocationReactiveComponent.swift
//  Forecast
//
//  Created by Julia Grasevych on 25.03.2024.
//

import Foundation
import SwiftUI

import NeedleFoundation

public class ForecastAddLocationReactiveComponent: Component<ForecastAddLocationReactiveDependency>, ForecastAddLocationViewBuilder {
    var viewModel: ForecastAddLocationViewModelReactive {
        ForecastAddLocationViewModelReactive(locationStorage: dependency.locationStorage)
    }
    
    @MainActor
    public var view: AnyView {
        AnyView(
            ForecastAddLocationView(
                viewModel: self.viewModel,
                searchBuilder: searchComponent
            )
        )
    }
    
    public var locationFinder: LocationSearchingReactive {
        LocationFinder()
    }
    
    var searchComponent: ForecastLocationSearchViewBuilder {
        ForecastLocationSearchReactiveComponent(parent: self)
    }
}
