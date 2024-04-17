//
//  LocationFinder.swift
//  Forecast
//
//  Created by Julia Grasevych on 20.02.2024.
//

import Foundation
import Combine
import MapKit
import ForecastDependency

public protocol LocationSearching {
    func search(query: String) async throws -> [String]
    func location(for query: String) async throws -> NamedLocation
}

public protocol LocationSearchingReactive {
    func search(query: String) -> AnyPublisher<[String], Swift.Error>
    func location(for query: String) -> AnyPublisher<NamedLocation, Swift.Error>
}

@globalActor
final class LocationFinder: NSObject, LocationSearching {
    actor ActorType { }
    static let shared = ActorType()
    
    enum Error: Swift.Error {
        case cancelled
        case locationNotFound
    }
    
    private let completer = MKLocalSearchCompleter()
    private var resultContinuation: CheckedContinuation<[String], Swift.Error>?
    
    private var searchResult = CurrentValueSubject<[String]?, Swift.Error>(nil)
    
    override init() {
        super.init()
        completer.delegate = self
    }
    
    func search(query: String) async throws -> [String] {
        guard !query.isEmpty else { return [] }
        resultContinuation?.resume(throwing: Error.cancelled)
        
        if completer.isSearching {
            completer.cancel()
        }
        return try await withCheckedThrowingContinuation { continuation in
            resultContinuation = continuation
            Task { @MainActor in
                self.completer.resultTypes = .address
                self.completer.queryFragment = query
            }
        }
    }
    
    func location(for query: String) async throws -> NamedLocation {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        searchRequest.resultTypes = .address
        let search = MKLocalSearch(request: searchRequest)
        guard let result = try await search.start()
            .mapItems
            .first
            .map({ item in
                NamedLocation(mapItem: item)
            })
        else {
            throw Error.locationNotFound
        }
        return result
    }
}

extension LocationFinder: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let searchResults = completer.results.map { item in
            return item.title + ", " + item.subtitle
        }
        resultContinuation?.resume(returning: searchResults)
        resultContinuation = nil
        
        searchResult.send(searchResults)
        searchResult.send(completion: .finished)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Swift.Error) {
        resultContinuation?.resume(throwing: error)
        resultContinuation = nil
        
        searchResult.send(completion: .failure(error))
    }
}

extension LocationFinder: LocationSearchingReactive {
    func search(query: String) -> AnyPublisher<[String], Swift.Error> {
        guard !query.isEmpty else {
            return Just([])
                .setFailureType(to: Swift.Error.self)
                .eraseToAnyPublisher()
        }
        if completer.isSearching {
            completer.cancel()
        }
        searchResult = CurrentValueSubject(nil)
        DispatchQueue.main.async {
            self.completer.resultTypes = .address
            self.completer.queryFragment = query
        }
        
        return searchResult
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    func location(for query: String) -> AnyPublisher<ForecastDependency.NamedLocation, Swift.Error> {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        searchRequest.resultTypes = .address
        let search = MKLocalSearch(request: searchRequest)
        
        return AnyPublisher<ForecastDependency.NamedLocation, Swift.Error>.single { promise in
            search.start { response, error in
                if let error {
                    promise(.failure(error))
                    return
                }
                guard let item = response?.mapItems.first else {
                    promise(.failure(Error.locationNotFound))
                    return
                }
                promise(.success(
                    NamedLocation(mapItem: item)
                ))
            }
        }
    }
}

fileprivate extension NamedLocation {
    init(mapItem: MKMapItem) {
        self.init(
            id: UUID().uuidString,
            name: mapItem.name ?? "N/A",
            placemark: mapItem.placemark,
            timeZoneIdentifier: mapItem.timeZone?.identifier
        )
    }
}
