//
//  ExternalLocationStoring.swift
//  ForecastDependency
//
//  Created by Julia Grasevych on 27.02.2024.
//

import Foundation
import Combine

public protocol ExternalLocationStoring: Sendable {
    func locations() async throws -> [NamedLocation]
    func add(location: NamedLocation) async throws -> [NamedLocation]
    func remove(location id: NamedLocation.ID) async throws -> [NamedLocation]
    
    var locationsPublisher: AnyPublisher<[NamedLocation], Error> { get }
    func addReactive(location: NamedLocation) -> AnyPublisher<Void, Error>
    func removeReactive(location id: NamedLocation.ID) -> AnyPublisher<Void, Error>
    
}
