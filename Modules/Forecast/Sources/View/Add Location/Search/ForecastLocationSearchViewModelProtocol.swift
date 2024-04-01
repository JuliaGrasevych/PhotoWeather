//
//  ForecastLocationSearchViewModelProtocol.swift
//  Forecast
//
//  Created by Julia Grasevych on 26.03.2024.
//

import Foundation
import SwiftUI

protocol ForecastLocationSearchViewModelProtocol: ObservableObject {
    var input: ForecastLocationSearchViewModelInput { get }
    var inputBinding: ObservedObject<ForecastLocationSearchViewModelInput>.Wrapper { get }
    var output: ForecastLocationSearchViewModelOutput { get }
    var outputBinding: ObservedObject<ForecastLocationSearchViewModelOutput>.Wrapper { get }
}
