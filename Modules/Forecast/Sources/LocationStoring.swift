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
    func locations() async throws -> AsyncStream<[NamedLocation]>
}

public protocol LocationManaging {
    func remove(location id: NamedLocation.ID) async throws
}

public protocol LocationManagingReactive {
    func remove(location id: NamedLocation.ID) -> AnyPublisher<Void, Error>
}
