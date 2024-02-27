//
//  ExternalLocationStore.swift
//  ForecastDependency
//
//  Created by Julia Grasevych on 27.02.2024.
//

import Foundation

public protocol ExternalLocationStore: Sendable {
    var locations: [NamedLocation] { get async }
    func add(location: NamedLocation) async -> [NamedLocation]
    func remove(location id: NamedLocation.ID) async -> [NamedLocation]
}
