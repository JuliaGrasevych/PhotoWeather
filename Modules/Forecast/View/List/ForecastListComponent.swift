//
//  ForecastListComponent.swift
//  Forecast
//
//  Created by Julia Grasevych on 16.02.2024.
//

import Foundation
import SwiftUI
import NeedleFoundation

public class ForecastListComponent: Component<ForecastListDependency> {
    var viewModel: ForecastListView.ViewModel {
        ForecastListView.ViewModel(
            locationStorage: dependency.locationStorage
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
    
    var itemComponent: ForecastLocationItemComponent {
        ForecastLocationItemComponent(parent: self)
    }
    
    var addLocationComponent: ForecastAddLocationComponent {
        ForecastAddLocationComponent(parent: self)
    }
}
