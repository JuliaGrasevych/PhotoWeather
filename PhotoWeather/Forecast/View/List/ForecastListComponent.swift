//
//  ForecastListComponent.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 16.02.2024.
//

import Foundation
import SwiftUI
import NeedleFoundation

class ForecastListComponent: Component<ForecastListDependency> {
    var viewModel: ForecastList.ViewModel {
        ForecastList.ViewModel(
            weatherFetcher: dependency.weatherFetcher,
            photoFetcher: dependency.photoFetcher
        )
    }
    
    var view: AnyView {
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
