//
//  SwiftDataStore.swift
//  Storage
//
//  Created by Julia Grasevych on 28.02.2024.
//

import Foundation
import SwiftData
import ForecastDependency

public final class SwiftDataStore: ExternalLocationStoring {
    private let modelContainer: ModelContainer
    private let context: ModelContext
    
    init() {
        do {
            modelContainer = try ModelContainer(for: NamedLocationModel.self)
        } catch {
            fatalError("Failed to create 'NamedLocation' model container")
        }
        context = ModelContext(modelContainer)
        context.autosaveEnabled = true
    }
    
    public func locations() async throws -> [NamedLocation] {
        let fetchDescriptor = FetchDescriptor<NamedLocationModel>()
        return try context.fetch(fetchDescriptor).map(\.userRepresentation)
    }
    
    public func add(location: NamedLocation) async throws -> [NamedLocation] {
        context.insert(NamedLocationModel(userRepresentation: location))
        try context.save()
        return try await locations()
    }
    
    public func remove(location id: NamedLocation.ID) async throws -> [NamedLocation] {
        let predicate = #Predicate<NamedLocationModel> {
            $0.id == id
        }
        try context.delete(model: NamedLocationModel.self, where: predicate)
        return try await locations()
    }
}

@Model
final class NamedLocationModel: ForecastLocation {
    public typealias ID = String
    
    @Attribute(.unique) public let id: String
    public let name: String
    public let latitude: Float
    public let longitude: Float
    public let timeZoneIdentifier: String?
    
    init(
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

extension NamedLocationModel {
    var userRepresentation: NamedLocation {
        NamedLocation(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            timeZoneIdentifier: timeZoneIdentifier
        )
    }
    
    convenience init(userRepresentation: NamedLocation) {
        self.init(
            id: userRepresentation.id,
            name: userRepresentation.name,
            latitude: userRepresentation.latitude,
            longitude: userRepresentation.longitude,
            timeZoneIdentifier: userRepresentation.timeZoneIdentifier
        )
    }
}
