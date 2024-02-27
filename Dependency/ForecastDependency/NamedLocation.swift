//
//  NamedLocation.swift
//  Forecast
//
//  Created by Julia Grasevych on 20.02.2024.
//

import Foundation
import CoreLocation

public struct NamedLocation: ForecastLocation {
    public typealias ID = String
    
    public let id: String
    public let name: String
    public var latitude: Float
    public var longitude: Float
    public var timeZoneIdentifier: String?
    
    public init(id: String, name: String, placemark: CLPlacemark) {
        self.id = id
        self.name = name
        self.latitude = Float(placemark.location?.coordinate.latitude ?? 0)
        self.longitude = Float(placemark.location?.coordinate.longitude ?? 0)
        self.timeZoneIdentifier = placemark.timeZone?.identifier
    }
}

extension NamedLocation: Sendable { }
extension NamedLocation: Codable { }
