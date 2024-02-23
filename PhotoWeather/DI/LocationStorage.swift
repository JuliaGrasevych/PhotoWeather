//
//  LocationStorage.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 22.02.2024.
//

import Foundation
import Forecast

actor LocationStorage: LocationStoring, LocationManaging {
    private var continuation: AsyncStream<[NamedLocation]>.Continuation?
    private lazy var locationsStream: AsyncStream<[NamedLocation]> = {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.yield(Array(internalLocationStore))
        }
    }()
    
    var internalLocationStore: Set<Forecast.NamedLocation> = [] {
        didSet {
            continuation?.yield(Array(internalLocationStore))
        }
    }
    
    func locations() async -> AsyncStream<[NamedLocation]> {
        locationsStream
    }
    
    func add(location: Forecast.NamedLocation) {
        internalLocationStore.insert(location)
    }
    
    func remove(location id: NamedLocation.ID) {
        guard let index = internalLocationStore.firstIndex(where: { $0.id == id }) else { return }
        internalLocationStore.remove(at: index)
    }
}

extension Forecast.NamedLocation: Hashable {
    public static func == (lhs: Forecast.NamedLocation, rhs: Forecast.NamedLocation) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

