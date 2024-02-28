//
//  NamedLocation.swift
//  Forecast
//
//  Created by Julia Grasevych on 20.02.2024.
//

import Foundation
import CoreLocation
import SwiftData

public struct NamedLocation: ForecastLocation {
    public typealias ID = String
    
    public let id: String
    public let name: String
    public let latitude: Float
    public let longitude: Float
    public let timeZoneIdentifier: String?
    
    public init(id: String, name: String, placemark: CLPlacemark) {
        self.id = id
        self.name = name
        self.latitude = Float(placemark.location?.coordinate.latitude ?? 0)
        self.longitude = Float(placemark.location?.coordinate.longitude ?? 0)
        self.timeZoneIdentifier = placemark.timeZone?.identifier
    }
    
    public init(
        id: String,
        name: String,
        latitude: Float,
        longitude: Float,
        timeZoneIdentifier: String?
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.timeZoneIdentifier = timeZoneIdentifier
    }
}

extension NamedLocation: Sendable { }
extension NamedLocation: Codable { }
extension NamedLocation: Equatable { 
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
