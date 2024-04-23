//
//  PhotoWeatherWidgetBundle.swift
//  PhotoWeatherWidget
//
//  Created by Julia Grasevych on 19.04.2024.
//

import WidgetKit
import SwiftUI

@main
struct PhotoWeatherWidgetBundle: WidgetBundle {
    init() {
        registerProviderFactories()
    }
    
    var body: some Widget {
        PhotoWeatherWidget()
    }
}
