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
    
    private let authorizationSubject: CurrentValueSubject<Bool, Never>
    private let currentLocationSubject = CurrentValueSubject<Result<CLLocation?, Error>, Never>(.success(nil))
    
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
        self.authorizationSubject = CurrentValueSubject(locationManager.authorizationStatus.isAuthorized)
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
                .denied,
                .authorizedAlways,
                .authorizedWhenInUse,
                .authorized:
            return locationManager.authorizationStatus.isAuthorized
        @unknown default:
            return locationManager.authorizationStatus.isAuthorized
        }
    }
}

extension LocationProvider: LocationProvidingReactive {
    public var currentLocationPublisher: AnyPublisher<CLLocation, any Error> {
        locationManager.requestLocation()
        return currentLocationSubject
        .tryCompactMap { result in
            switch result {
            case .success(let location):
                return location
            case .failure(let error):
                throw error
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func isAuthorized() -> AnyPublisher<Bool, Never> {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return authorizationSubject.eraseToAnyPublisher()
        case .restricted,
                .denied,
                .authorizedAlways,
                .authorizedWhenInUse,
                .authorized:
            return authorizationSubject.eraseToAnyPublisher()
        @unknown default:
            return authorizationSubject.eraseToAnyPublisher()
        }
    }
}

extension LocationProvider: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            return
        }
        currentLocationSubject.send(.success(lastLocation))
        guard case let .pending(array) = locationState else { return }
        array.forEach { continuation in
            continuation.resume(returning: lastLocation)
        }
        self.locationState = .empty
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocationSubject.send(.failure(error))
        guard case let .pending(array) = locationState else { return }
        array.forEach { continuation in
            continuation.resume(throwing: error)
        }
        self.locationState = .empty
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let isAuthorized = locationManager.authorizationStatus.isAuthorized
        authorizationContinuation?.resume(returning: isAuthorized)
        authorizationSubject.send(isAuthorized)
        authorizationContinuation = nil
    }
}

extension CLAuthorizationStatus {
    var isAuthorized: Bool {
        switch self {
        case .notDetermined,
                .restricted,
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
