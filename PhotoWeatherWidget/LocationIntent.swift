//
//  LocationIntent.swift
//  PhotoWeatherWidget
//
//  Created by Julia Grasevych on 26.04.2024.
//

import Foundation
import AppIntents

struct LocationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Title"
    
    @Parameter(title: "Location")
    var location: LocationAppEntity
}
