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
    private let locationStorage: LocationStoring = PhotoWeatherWidget.rootComponent.locationStorage
    
    func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
       let result = try await locationStorage.getLocations()
            .filter { item in identifiers.contains(where: { $0 == item.id }) }
            .map(LocationAppEntity.init)
        return result
    }
    
    func suggestedEntities() async throws -> [LocationAppEntity] {
        let results = try await locationStorage.getLocations()
            .map(LocationAppEntity.init)
        return results
    }
    
    func defaultResult() async -> LocationAppEntity? {
        nil
    }
}
