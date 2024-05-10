//
//  ForecastReactiveComponent.swift
//  Forecast
//
//  Created by Julia Grasevych on 21.03.2024.
//

import Foundation
import SwiftUI
import NeedleFoundation
import ForecastDependency

public class ForecastReactiveComponent: Component<ForecastComponentDependency>, ForecastComponentProtocol {
    // MARK: - Child Dependencies
    public var weatherFetcher: ForecastFetchingReactive {
        shared {
            ForecastFetcher(networkService: dependency.networkService)
        }
    }
    // TODO: make reactive?
    public var weatherFetcherExport: ForecastFetching {
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
    
    @MainActor
    public func widgetView(viewModel: ForecastLocationItemWidgetViewModel) -> AnyView {
        ForecastLocationItemReactiveComponent(parent: self)
            .widgetView(viewModel: viewModel)
    }
}
