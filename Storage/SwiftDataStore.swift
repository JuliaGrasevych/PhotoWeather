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

public final actor SwiftDataStore: ExternalLocationStoring, ModelActor {
    public let modelExecutor: any ModelExecutor
    
    public let modelContainer: ModelContainer
    // I didn't manage to get model context notifications working,
    // so resorted to rx subject
    private let modelContextDidChange: PassthroughSubject<Void, Never>
    
    init() {
        do {
            modelContainer = try ModelContainer(for: NamedLocationModel.self)
        } catch {
            fatalError("Failed to create 'NamedLocation' model container")
        }
        
        let context = ModelContext(modelContainer)
        context.autosaveEnabled = true
        modelExecutor = DefaultSerialModelExecutor(modelContext: context)
        
        let fetchDescriptor = FetchDescriptor<NamedLocationModel>()
        let mcdc = PassthroughSubject<Void, Never>()
        self.modelContextDidChange = mcdc
        
        do {
            let items = try context.fetch(fetchDescriptor).map(\.userRepresentation)
            locationsPublisher = Just(items)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
                .merge(with: Self.contextDidChangePublisher(
                    context: context,
                    modelContextDidChange: mcdc.eraseToAnyPublisher(),
                    fetchDescriptor: fetchDescriptor
                ))
                .removeDuplicates()
                .eraseToAnyPublisher()
        } catch {
            locationsPublisher = Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    private static func contextDidChangePublisher(
        context: @escaping @autoclosure () -> ModelContext,
        modelContextDidChange: AnyPublisher<Void, Never>,
        fetchDescriptor: FetchDescriptor<NamedLocationModel>
    ) -> AnyPublisher<[NamedLocation], Error> {
        modelContextDidChange
            .setFailureType(to: Error.self)
            .tryMap { _ in
                try context().fetch(fetchDescriptor).map(\.userRepresentation)
            }
            .eraseToAnyPublisher()
    }
    
    public func locations() async throws -> [NamedLocation] {
        let fetchDescriptor = FetchDescriptor<NamedLocationModel>()
        return try modelContext.fetch(fetchDescriptor).map(\.userRepresentation)
    }
    
    private func insert(location: NamedLocation) throws {
        modelContext.insert(NamedLocationModel(userRepresentation: location))
        try modelContext.save()
        modelContextDidChange.send()
    }
    
    private func delete(location id: NamedLocation.ID) throws {
        let predicate = #Predicate<NamedLocationModel> {
            $0.id == id
        }
        try modelContext.delete(model: NamedLocationModel.self, where: predicate)
        try modelContext.save()
        modelContextDidChange.send()
    }
    
    public func add(location: NamedLocation) async throws -> [NamedLocation] {
        try insert(location: location)
        return try await locations()
    }
    
    public func remove(location id: NamedLocation.ID) async throws -> [NamedLocation] {
        try delete(location: id)
        return try await locations()
    }
    
    nonisolated
    public let locationsPublisher: AnyPublisher<[NamedLocation], any Error>
    
    nonisolated
    public func addReactive(location: NamedLocation) -> AnyPublisher<Void, any Error> {
        AnyPublisher<Void, any Error>.single { promise in
            Task {
                do {
                    try await self.insert(location: location)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    
    nonisolated
    public func removeReactive(location id: NamedLocation.ID) -> AnyPublisher<Void, any Error> {
        AnyPublisher<Void, any Error>.single { promise in
            Task {
                do {
                    try await self.delete(location: id)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
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
