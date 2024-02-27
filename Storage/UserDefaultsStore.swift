//
//  UserDefaultsStore.swift
//  Storage
//
//  Created by Julia Grasevych on 27.02.2024.
//

import Foundation
import Core
import ForecastDependency

public actor UserDefaultsStore: ExternalLocationStore {
    static let locationsStoreKey = "com.photoWeather.locationStoreKey"
    private let userDefaults: UserDefaults
    
    public var locations: [NamedLocation] {
        get async {
            (try? userDefaults.getObject(forKey: Self.locationsStoreKey, castTo: [NamedLocation].self)) ?? []
        }
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    public func add(location: NamedLocation) async -> [NamedLocation] {
        var locationsArray = await self.locations
        guard !locationsArray.contains(where: { $0.id == location.id }) else {
            return await locations
        }
        locationsArray.append(location)
        try? userDefaults.setObject(locationsArray, forKey: Self.locationsStoreKey)
        return await locations
    }
    
    public func remove(location id: NamedLocation.ID) async -> [NamedLocation] {
        var locationsArray = await self.locations
        locationsArray.removeAll(where: { $0.id == id })
        try? userDefaults.setObject(locationsArray, forKey: Self.locationsStoreKey)
        return await locations
    }
}
