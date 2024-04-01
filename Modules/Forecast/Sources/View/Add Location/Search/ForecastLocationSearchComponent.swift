//
//  ForecastLocationSearchComponent.swift
//  Forecast
//
//  Created by Julia Grasevych on 20.02.2024.
//

import Foundation
import SwiftUI
import NeedleFoundation
import ForecastDependency

public protocol ForecastLocationSearchViewBuilder {
    func view(locationBinding: Binding<NamedLocation?>) -> AnyView
}

public class ForecastLocationSearchComponent: Component<ForecastLocationSearchDependency>, ForecastLocationSearchViewBuilder {
    var viewModel: ForecastLocationSearchViewModel {
        ForecastLocationSearchViewModel(locationFinder: dependency.locationFinder)
    }
    
    @MainActor
    public func view(locationBinding: Binding<NamedLocation?>) -> AnyView {
        AnyView(
            ForecastLocationSearchView(
                viewModel: self.viewModel,
                location: locationBinding
            )
        )
    }
}
