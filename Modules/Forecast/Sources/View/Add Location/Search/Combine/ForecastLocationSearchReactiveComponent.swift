//
//  ForecastLocationSearchReactiveComponent.swift
//  Forecast
//
//  Created by Julia Grasevych on 26.03.2024.
//

import Foundation
import SwiftUI

import NeedleFoundation
import ForecastDependency

public class ForecastLocationSearchReactiveComponent: Component<ForecastLocationSearchReactiveDependency>, ForecastLocationSearchViewBuilder {
    var viewModel: ForecastLocationSearchViewModelReactive {
        ForecastLocationSearchViewModelReactive(locationFinder: dependency.locationFinder)
    }
    
    @MainActor
    public func view(locationBinding: Binding<NamedLocation?>, isPresented: Binding<Bool>) -> AnyView {
        AnyView(
            ForecastLocationSearchView(
                viewModel: self.viewModel,
                location: locationBinding,
                isPresented: isPresented
            )
        )
    }
}
