//
//  ForecastComponent.swift
//  Forecast
//
//  Created by Julia Grasevych on 16.02.2024.
//

import Foundation
import SwiftUI
import NeedleFoundation
import Core
import ForecastDependency

public protocol ForecastComponentDependency: Dependency {
    var networkService: NetworkServiceProtocol { get }
}

public protocol ForecastComponentProtocol {
    var view: AnyView { get }
    var weatherFetcherExport: ForecastFetching { get }
    func widgetView(viewModel: ForecastLocationItemWidgetViewModel) -> AnyView
}

public class ForecastComponent: Component<ForecastComponentDependency>, ForecastComponentProtocol {
    // MARK: - Child Dependencies
    public var weatherFetcher: ForecastFetching {
        shared {
            ForecastFetcher(networkService: dependency.networkService)
        }
    }
    
    public var weatherFetcherExport: ForecastFetching {
        weatherFetcher
    }
    
    @MainActor
    public var view: AnyView {
        childComponent.view
    }
    
    var childComponent: ForecastListComponent {
        ForecastListComponent(parent: self)
    }
    
    @MainActor
    public func widgetView(viewModel: ForecastLocationItemWidgetViewModel) -> AnyView {
        ForecastLocationItemComponent(parent: self)
            .widgetView(viewModel: viewModel)
    }
}
