//
//  SwiftDataStore.swift
//  Storage
//
//  Created by Julia Grasevych on 28.02.2024.
//

import Foundation
import Combine
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
        
        let fetchDescriptor = FetchDescriptor<NamedLocationModel>()
        do {
            let items = try context.fetch(fetchDescriptor).map(\.userRepresentation)
            locationsPublisher = Just(items)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
                .merge(with: Self.contextDidChangePublisher(context: context, fetchDescriptor: fetchDescriptor))
                .removeDuplicates()
                .eraseToAnyPublisher()
        } catch {
            locationsPublisher = Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    private static func contextDidChangePublisher(context: ModelContext, fetchDescriptor: FetchDescriptor<NamedLocationModel>) -> AnyPublisher<[NamedLocation], Error> {
        NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange, object: context)
            .setFailureType(to: Error.self)
            .tryMap { _ in
                try context.fetch(fetchDescriptor).map(\.userRepresentation)
            }
            .eraseToAnyPublisher()
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
        try context.save()
        return try await locations()
    }
    
    public let locationsPublisher: AnyPublisher<[NamedLocation], any Error>
    
    public func addReactive(location: NamedLocation) -> AnyPublisher<Void, any Error> {
        context.insert(NamedLocationModel(userRepresentation: location))
        do {
            try context.save()
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    public func removeReactive(location id: NamedLocation.ID) -> AnyPublisher<Void, any Error> {
        let predicate = #Predicate<NamedLocationModel> {
            $0.id == id
        }
        do {
            try context.delete(model: NamedLocationModel.self, where: predicate)
            try context.save()
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}

@Model
final class NamedLocationModel {
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
