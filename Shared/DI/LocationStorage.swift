//
//  LocationStorage.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 22.02.2024.
//

import Foundation
import Combine
import Forecast
import ForecastDependency

actor LocationStorage: LocationStoring, LocationManaging {
    private let externalStore: ExternalLocationStoring
    private var continuation: AsyncStream<[NamedLocation]>.Continuation?
    private lazy var locationsStream: AsyncStream<[NamedLocation]> = {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.yield(Array(internalLocationStore))
        }
    }()
    
    var internalLocationStore: [NamedLocation] = [] {
        didSet {
            guard oldValue != internalLocationStore else { return }
            continuation?.yield(internalLocationStore)
        }
    }
    
    init(externalStore: ExternalLocationStoring) {
        self.externalStore = externalStore
    }
    
    func locations() async throws -> AsyncStream<[NamedLocation]> {
        internalLocationStore = try await externalStore.locations()
        return locationsStream
    }
    
    func add(location: NamedLocation) async throws {
        internalLocationStore = try await externalStore.add(location: location)
    }
    
    func remove(location id: NamedLocation.ID) async throws {
        internalLocationStore = try await externalStore.remove(location: id)
    }
}

extension LocationStorage: LocationManagingReactive {
    nonisolated 
    func remove(location id: NamedLocation.ID) -> AnyPublisher<Void, any Error> {
        externalStore.removeReactive(location: id)
    }
}

extension LocationStorage: LocationStoringReactive {
    nonisolated
    func add(location: NamedLocation) -> AnyPublisher<Void, any Error> {
        externalStore.addReactive(location: location)
    }
    
    nonisolated
    func locations() -> AnyPublisher<[NamedLocation], any Error> {
        externalStore.locationsPublisher
    }
}
