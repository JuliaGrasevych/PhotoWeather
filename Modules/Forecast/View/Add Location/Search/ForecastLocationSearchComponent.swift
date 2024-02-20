//
//  ForecastLocationSearchComponent.swift
//  Forecast
//
//  Created by Julia Grasevych on 20.02.2024.
//

import Foundation
import SwiftUI
import NeedleFoundation

public protocol ForecastLocationSearchViewBuilder {
    var view: AnyView { get }
}

public class ForecastLocationSearchComponent: Component<ForecastLocationSearchDependency>, ForecastLocationSearchViewBuilder {
    var viewModel: ForecastLocationSearchView.ViewModel {
        ForecastLocationSearchView.ViewModel(locationFinder: dependency.locationFinder)
    }
    
    public var view: AnyView {
        AnyView(
            ForecastLocationSearchView(viewModel: self.viewModel)
        )
    }
}
