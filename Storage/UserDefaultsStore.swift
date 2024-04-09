//
//  UserDefaultsStore.swift
//  Storage
//
//  Created by Julia Grasevych on 27.02.2024.
//

import Foundation
import Combine
import Core
import ForecastDependency

public actor UserDefaultsStore: ExternalLocationStoring {
    static let locationsStoreKey = "com.photoWeather.locationStoreKey"
    private let userDefaults: UserDefaults
    
    public func locations() async throws -> [NamedLocation] {
        try userDefaults.getObject(forKey: Self.locationsStoreKey, castTo: [NamedLocation].self)
    }
    
    nonisolated
    public var locationsPublisher: AnyPublisher<[NamedLocation], any Error> {
        do {
            let items = try userDefaults.getObject(forKey: Self.locationsStoreKey, castTo: [NamedLocation].self)
            return Just(items)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    public func add(location: NamedLocation) async throws -> [NamedLocation] {
        var locationsArray = try await self.locations()
        guard !locationsArray.contains(where: { $0.id == location.id }) else {
            return locationsArray
        }
        locationsArray.append(location)
        try userDefaults.setObject(locationsArray, forKey: Self.locationsStoreKey)
        return try await locations()
    }
    
    public func remove(location id: NamedLocation.ID) async throws -> [NamedLocation] {
        var locationsArray = try await self.locations()
        locationsArray.removeAll(where: { $0.id == id })
        try userDefaults.setObject(locationsArray, forKey: Self.locationsStoreKey)
        return try await locations()
    }
    
    nonisolated 
    public func addReactive(location: NamedLocation) -> AnyPublisher<Void, any Error> {
        locationsPublisher
            .flatMap { [self] locationsArray in
                guard !locationsArray.contains(where: { $0.id == location.id }) else {
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                var updatedArray = locationsArray
                updatedArray.append(location)
                do {
                    try userDefaults.setObject(updatedArray, forKey: Self.locationsStoreKey)
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    nonisolated 
    public func removeReactive(location id: NamedLocation.ID) -> AnyPublisher<Void, any Error> {
        locationsPublisher
            .flatMap { locationsArray in
                var updatedArray = locationsArray
                updatedArray.removeAll(where: { $0.id == id })
                do {
                    try self.userDefaults.setObject(updatedArray, forKey: Self.locationsStoreKey)
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
