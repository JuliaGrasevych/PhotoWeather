//
//  LocationManager.swift
//  Core
//
//  Created by Julia Grasevych on 05.03.2024.
//

import Foundation
import CoreLocation

public protocol LocationProviding {
    var currentLocation: CLLocation { get async throws }
    func isAuthorized() async -> Bool
}

public class LocationProvider: NSObject, LocationProviding {
    private let locationManager: CLLocationManager
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var authorizationContinuation: CheckedContinuation<Bool, Never>?
    
    public var currentLocation: CLLocation {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                self.locationContinuation = continuation
                locationManager.requestLocation()
            }
        }
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

extension LocationProvider: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            return
        }
        locationContinuation?.resume(returning: lastLocation)
        locationContinuation = nil
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
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
