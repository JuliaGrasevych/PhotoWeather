//
//  Deeplink.swift
//  Forecast
//
//  Created by Julia Grasevych on 07.05.2024.
//

import Foundation

extension URL {
    static let deeplinkScheme: String = "photoWeather"
    static let locationDeeplinkHost: String = "location"
    
    static func locationDeeplinkURL(locationId: String) -> URL? {
        URL(string: "\(Self.deeplinkScheme)://\(Self.locationDeeplinkHost)/\(locationId)")
    }
}
