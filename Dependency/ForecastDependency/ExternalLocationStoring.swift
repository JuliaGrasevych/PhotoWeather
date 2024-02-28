//
//  ExternalLocationStoring.swift
//  ForecastDependency
//
//  Created by Julia Grasevych on 27.02.2024.
//

import Foundation

public protocol ExternalLocationStoring: Sendable {
    func locations() async throws -> [NamedLocation]
    func add(location: NamedLocation) async throws -> [NamedLocation]
    func remove(location id: NamedLocation.ID) async throws -> [NamedLocation]
}
