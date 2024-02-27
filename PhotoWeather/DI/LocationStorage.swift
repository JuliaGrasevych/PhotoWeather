//
//  LocationStorage.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 22.02.2024.
//

import Foundation
import Forecast
import ForecastDependency

actor LocationStorage: LocationStoring, LocationManaging {
    private let externalStore: ExternalLocationStore
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
    
    init(externalStore: ExternalLocationStore) {
        self.externalStore = externalStore
    }
    
    func locations() async -> AsyncStream<[NamedLocation]> {
        internalLocationStore = await externalStore.locations
        return locationsStream
    }
    
    func add(location: NamedLocation) async {
        internalLocationStore = await externalStore.add(location: location)
    }
    
    func remove(location id: NamedLocation.ID) async {
        internalLocationStore = await externalStore.remove(location: id)
    }
}

extension NamedLocation: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
