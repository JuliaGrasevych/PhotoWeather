//
//  UserDefaultsStore.swift
//  Storage
//
//  Created by Julia Grasevych on 27.02.2024.
//

import Foundation
import Core
import ForecastDependency

public actor UserDefaultsStore: ExternalLocationStoring {
    static let locationsStoreKey = "com.photoWeather.locationStoreKey"
    private let userDefaults: UserDefaults
    
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
    
    public func locations() async throws -> [NamedLocation] {
        try userDefaults.getObject(forKey: Self.locationsStoreKey, castTo: [NamedLocation].self)
    }
}
