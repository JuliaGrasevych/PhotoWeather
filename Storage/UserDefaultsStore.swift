//
//  UserDefaultsStore.swift
//  Storage
//
//  Created by Julia Grasevych on 27.02.2024.
//

import Foundation
import Combine
import Core
import ForecastDependency

public actor UserDefaultsStore: ExternalLocationStoring {
    static let locationsStoreKey = "com.photoWeather.locationStoreKey"
    private let userDefaults: UserDefaults
    
    private let locationsSubject: CurrentValueSubject<[NamedLocation], Error>
    private var cancellables = [AnyCancellable]()
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        
        locationsSubject = CurrentValueSubject([])
        userDefaults.publisher(for: \.locationsData)
            .tryMap { data in
                guard let data else {
                    return []
                }
                do {
                    let object = try [NamedLocation].decoded(from: data)
                    return object
                } catch {
                    throw ObjectSavableError.unableToDecode
                }
            }
            .eraseToAnyPublisher()
            .subscribe(locationsSubject)
            .store(in: &cancellables)
    }
    
    public func locations() async throws -> [NamedLocation] {
        do {
            return try userDefaults.getObject(forKey: Self.locationsStoreKey, castTo: [NamedLocation].self)
        } catch {
            guard case ObjectSavableError.noValue = error else {
                throw error
            }
            return []
        }
    }
    
    public func add(location: NamedLocation) async throws -> [NamedLocation] {
        var locationsArray = try await self.locations()
        guard !locationsArray.contains(where: { $0.id == location.id }) else {
            return locationsArray
        }
        locationsArray.append(location)
        try userDefaults.setObject(locationsArray, forKey: Self.locationsStoreKey)
        return try await locations()
    }
    
    public func remove(location id: NamedLocation.ID) async throws -> [NamedLocation] {
        var locationsArray = try await self.locations()
        locationsArray.removeAll(where: { $0.id == id })
        try userDefaults.setObject(locationsArray, forKey: Self.locationsStoreKey)
        return try await locations()
    }
    
    nonisolated
    public private(set) lazy var locationsPublisher: AnyPublisher<[NamedLocation], any Error> = locationsSubject.eraseToAnyPublisher()
    
    nonisolated
    public func addReactive(location: NamedLocation) -> AnyPublisher<Void, any Error> {
        locationsPublisher
            .prefix(1)
            .flatMap { [weak self] locationsArray in
                guard let self else {
                    return Empty<Void, Error>(completeImmediately: true)
                        .eraseToAnyPublisher()
                }
                
                guard !locationsArray.contains(where: { $0.id == location.id }) else {
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                var updatedArray = locationsArray
                updatedArray.append(location)
                do {
                    let data = try updatedArray.encodedData()
                    self.userDefaults.locationsData = data
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    nonisolated
    public func removeReactive(location id: NamedLocation.ID) -> AnyPublisher<Void, any Error> {
        locationsPublisher
            .prefix(1)
            .flatMap { [weak self]  locationsArray in
                guard let self else {
                    return Empty<Void, Error>(completeImmediately: true)
                        .eraseToAnyPublisher()
                }
                var updatedArray = locationsArray
                updatedArray.removeAll(where: { $0.id == id })
                do {
                    let data = try updatedArray.encodedData()
                    self.userDefaults.locationsData = data
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

extension UserDefaults {
    @objc var locationsData: Data? {
        get { data(forKey: UserDefaultsStore.locationsStoreKey) }
        set { set(newValue, forKey: UserDefaultsStore.locationsStoreKey) }
    }
}
