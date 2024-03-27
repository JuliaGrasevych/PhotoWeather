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
    nonisolated func remove(location id: NamedLocation.ID) -> AnyPublisher<Void, any Error> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        try await self.remove(location: id)
                        // TODO: how to access promise in async context?
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension LocationStorage: LocationStoringReactive {
    nonisolated func add(location: NamedLocation) -> AnyPublisher<Void, any Error> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        try await self.add(location: location)
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    nonisolated func locations() -> AnyPublisher<[NamedLocation], any Error> {
        let subject = PassthroughSubject<[NamedLocation], Error>()
        Task {
            do {
                let asyncLocationsStream = try await self.locations()
                for await element in asyncLocationsStream {
                    subject.send(element)
                }
            } catch {
                subject.send(completion: .failure(error))
            }
        }
        return subject.eraseToAnyPublisher()
    }
}
