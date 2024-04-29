//
//  LocationAppEntity.swift
//  PhotoWeatherWidget
//
//  Created by Julia Grasevych on 26.04.2024.
//

import Foundation
import AppIntents
import Forecast
import ForecastDependency

struct LocationAppEntity: AppEntity, ForecastLocation {
    typealias DefaultQuery = LocationQuery
    
    var id: String
    var name: String
    var isUserLocation: Bool = false
    var timeZoneIdentifier: String?
    var latitude: Float
    var longitude: Float
    
    static var defaultQuery: LocationQuery = LocationQuery()
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Location"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

extension LocationAppEntity {
    init(forecastLocation: any ForecastLocation) {
        self.init(
            id: forecastLocation.id,
            name: forecastLocation.name,
            timeZoneIdentifier: forecastLocation.timeZoneIdentifier,
            latitude: forecastLocation.latitude,
            longitude: forecastLocation.longitude
        )
    }
}

struct LocationQuery: EntityQuery {
    let locationStorage: LocationStoring = PhotoWeatherWidget.rootComponent.locationStorage
    
    func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
        try await locationStorage.getLocations()
            .filter { item in identifiers.contains(where: { $0 == item.id }) }
            .map(LocationAppEntity.init)
    }
    
    func suggestedEntities() async throws -> [LocationAppEntity] {
        try await locationStorage.getLocations()
            .map(LocationAppEntity.init)
    }
    
    func defaultResult() async -> LocationAppEntity? {
        nil
    }
}
