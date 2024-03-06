//
//  LocationProvider+NamedLocation.swift
//  Forecast
//
//  Created by Julia Grasevych on 05.03.2024.
//

import Foundation
import CoreLocation
import Core
import ForecastDependency

enum LocationProviderError: Error {
    case failedGetLocation
}

struct NamedCurrentLocation: ForecastLocation {
    var id: String { "current_location" }
    var name: String
    var isUserLocation: Bool { true }
    var timeZoneIdentifier: String?
    var latitude: Float
    var longitude: Float
    
    init(
        name: String,
        placemark: CLPlacemark,
        timeZoneIdentifier: String?
    ) {
        self.name = name
        self.latitude = Float(placemark.location?.coordinate.latitude ?? 0)
        self.longitude = Float(placemark.location?.coordinate.longitude ?? 0)
        self.timeZoneIdentifier = timeZoneIdentifier
    }
}

extension LocationProviding {
    var currentForecastLocation: any ForecastLocation {
        get async throws {
            let location = try await currentLocation
            return try await withCheckedThrowingContinuation { continuation in
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    guard error == nil, let placemark = placemarks?.first else {
                        continuation.resume(throwing: LocationProviderError.failedGetLocation)
                        return
                    }
                    let location = NamedCurrentLocation(
                        name: placemark.placeName ?? "N/A",
                        placemark: placemark,
                        timeZoneIdentifier: placemark.timeZone?.identifier
                    )
                    continuation.resume(returning: location)
                }
            }
        }
    }
}

extension CLPlacemark {
    var placeName: String? {
        locality
        ?? subLocality
        ?? name
        ?? administrativeArea
        ?? subAdministrativeArea
        ?? country
    }
}
