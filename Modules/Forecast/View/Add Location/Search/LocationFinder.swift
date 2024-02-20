//
//  LocationFinder.swift
//  Forecast
//
//  Created by Julia Grasevych on 20.02.2024.
//

import Foundation
import MapKit

public protocol LocationSearching {
    func search(query: String) async throws -> [String]
}

@globalActor
final class LocationFinder: NSObject, LocationSearching {
    actor ActorType { }
    static let shared = ActorType()
    
    enum Error: Swift.Error {
        case cancelled
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
            DispatchQueue.main.async {
                self.completer.resultTypes = .address
                self.completer.queryFragment = query
            }
        }
    }
}

extension LocationFinder: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let searchResults = completer.results.map { item in
            return item.title + " " + item.subtitle
        }
        let continuation = resultContinuation
        resultContinuation = nil
        continuation?.resume(returning: searchResults)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Swift.Error) {
        let continuation = resultContinuation
        resultContinuation = nil
        continuation?.resume(throwing: error)
    }
}
