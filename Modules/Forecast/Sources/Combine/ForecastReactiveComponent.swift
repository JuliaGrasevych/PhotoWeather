//
//  ForecastReactiveComponent.swift
//  Forecast
//
//  Created by Julia Grasevych on 21.03.2024.
//

import Foundation
import SwiftUI
import NeedleFoundation

public class ForecastReactiveComponent: Component<ForecastComponentDependency>, ForecastComponentProtocol {
    // MARK: - Child Dependencies
    public var weatherFetcher: ForecastFetchingReactive {
        shared {
            ForecastFetcher(networkService: dependency.networkService)
        }
    }
    
    @MainActor
    public var view: AnyView {
        AnyView(
            childComponent.view
        )
    }
    
    var childComponent: ForecastListReactiveComponent {
        ForecastListReactiveComponent(parent: self)
    }
}
