//
//  LocationManager.swift
//  Core
//
//  Created by Julia Grasevych on 05.03.2024.
//

import Foundation
import Combine
import CoreLocation

public protocol LocationProviding {
    var currentLocation: CLLocation { get async throws }
    func isAuthorized() async -> Bool
}

public protocol LocationProvidingReactive {
    var currentLocationPublisher: AnyPublisher<CLLocation, Error> { get }
    func isAuthorized() -> AnyPublisher<Bool, Never>
}

public class LocationProvider: NSObject, LocationProviding {
    private typealias LocationContinuation = CheckedContinuation<CLLocation, Error>
    private enum LocationState {
        case empty
        case pending([LocationContinuation])
    }
    
    private let locationManager: CLLocationManager
    private var authorizationContinuation: CheckedContinuation<Bool, Never>?
    
    private var locationState = LocationState.empty
    
    public var currentLocation: CLLocation {
        get async throws {
            switch locationState {
            case .pending:
                return try await withCheckedThrowingContinuation { continuation in
                    trackContinuation(continuation)
                }
            case .empty:
                self.locationState = .pending([])
                return try await withCheckedThrowingContinuation { continuation in
                    trackContinuation(continuation)
                    locationManager.requestLocation()
                }
            }
        }
    }
    
    private func trackContinuation(_ continuation: LocationContinuation) {
        guard case var .pending(array) = locationState else { return }
        array.append(continuation)
        self.locationState = .pending(array)
    }
    
    public init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
    }
    
    public func isAuthorized() async -> Bool {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                self.authorizationContinuation = continuation
                locationManager.requestWhenInUseAuthorization()
            }
        case .restricted,
                .denied:
            return false
        case .authorizedAlways,
                .authorizedWhenInUse,
                .authorized:
            return true
        @unknown default:
            return false
        }
    }
}

extension LocationProvider: LocationProvidingReactive {
    public var currentLocationPublisher: AnyPublisher<CLLocation, any Error> {
        AnyPublisher<CLLocation, Error>.single { promise in
            Task {
                do {
                    let location = try await self.currentLocation
                    promise(.success(location))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func isAuthorized() -> AnyPublisher<Bool, Never> {
        AnyPublisher<Bool, Never>.single { promise in
            Task {
                let isAuthorized = await self.isAuthorized()
                promise(.success(isAuthorized))
            }
        }
        .eraseToAnyPublisher()
    }
}

extension LocationProvider: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            return
        }
        guard case let .pending(array) = locationState else { return }
        array.forEach { continuation in
            continuation.resume(returning: lastLocation)
        }
        self.locationState = .empty
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard case let .pending(array) = locationState else { return }
        array.forEach { continuation in
            continuation.resume(throwing: error)
        }
        self.locationState = .empty
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch locationManager.authorizationStatus {
        case .notDetermined,
                .restricted,
                .denied:
            authorizationContinuation?.resume(returning: false)
        case .authorizedAlways,
                .authorizedWhenInUse,
                .authorized:
            authorizationContinuation?.resume(returning: true)
        @unknown default:
            authorizationContinuation?.resume(returning: false)
        }
        authorizationContinuation = nil
    }
}
