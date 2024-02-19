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
    var viewModel: ForecastList.ViewModel {
        ForecastList.ViewModel(
            weatherFetcher: dependency.weatherFetcher,
            photoFetcher: dependency.photoFetcher
        )
    }
    
    public var view: AnyView {
        AnyView(
            ForecastList(
                viewModel: self.viewModel,
                itemBuilder: itemComponent
            )
        )
    }
    
    var itemComponent: ForecastLocationItemComponent {
        ForecastLocationItemComponent(parent: self)
    }
}
