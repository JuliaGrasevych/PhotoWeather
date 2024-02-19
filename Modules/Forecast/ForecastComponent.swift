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

public protocol ForecastComponentDependency: Dependency {
    var networkService: NetworkServiceProtocol { get }
}

public class ForecastComponent: Component<ForecastComponentDependency> {
    // MARK: - Child Dependencies
    public var weatherFetcher: ForecastFetching {
        shared {
            ForecastFetcher(networkService: dependency.networkService)
        }
    }
    
    public var view: AnyView {
        AnyView(
            childComponent.view
        )
    }
    
    var childComponent: ForecastListComponent {
        ForecastListComponent(parent: self)
    }
}
