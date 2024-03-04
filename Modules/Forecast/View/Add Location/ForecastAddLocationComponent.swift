//
//  ForecastAddLocationComponent.swift
//  Forecast
//
//  Created by Julia Grasevych on 20.02.2024.
//

import Foundation
import SwiftUI
import NeedleFoundation

public protocol ForecastAddLocationViewBuilder {
    var view: AnyView { get }
}

public class ForecastAddLocationComponent: Component<ForecastAddLocationDependency>, ForecastAddLocationViewBuilder {
    var viewModel: ForecastAddLocationView.ViewModel {
        ForecastAddLocationView.ViewModel(locationStorage: dependency.locationStorage)
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
    
    public var locationFinder: LocationSearching {
        LocationFinder()
    }
    
    var searchComponent: ForecastLocationSearchComponent {
        ForecastLocationSearchComponent(parent: self)
    }
}

