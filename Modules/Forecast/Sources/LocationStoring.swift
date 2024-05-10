//
//  LocationStoring.swift
//  Forecast
//
//  Created by Julia Grasevych on 23.02.2024.
//

import Foundation
import Combine
import ForecastDependency

public protocol LocationStoring {
    func add(location: NamedLocation) async throws
    /// Get location as updated async stream
    func locations() async throws -> AsyncStream<[NamedLocation]>
    /// Get locations as one-time list
    func getLocations() async throws -> [NamedLocation]
}

public protocol LocationStoringReactive {
    func add(location: NamedLocation) -> AnyPublisher<Void, Error>
    func locations() -> AnyPublisher<[NamedLocation], Error>
}

public protocol LocationManaging {
    func remove(location id: NamedLocation.ID) async throws
}

public protocol LocationManagingReactive {
    func remove(location id: NamedLocation.ID) -> AnyPublisher<Void, Error>
}
