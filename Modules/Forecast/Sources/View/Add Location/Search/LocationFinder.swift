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
                NamedLocation(
                    id: UUID().uuidString,
                    name: item.name ?? "N/A",
                    placemark: item.placemark,
                    timeZoneIdentifier: item.timeZone?.identifier
                )
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
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Swift.Error) {
        resultContinuation?.resume(throwing: error)
        resultContinuation = nil
    }
}

extension LocationFinder: LocationSearchingReactive {
    func search(query: String) -> AnyPublisher<[String], Swift.Error> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        let result = try await self.search(query: query)
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func location(for query: String) -> AnyPublisher<ForecastDependency.NamedLocation, Swift.Error> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        let result = try await self.location(for: query)
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
