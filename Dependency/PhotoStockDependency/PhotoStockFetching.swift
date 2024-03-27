//
//  PhotoStockFetching.swift
//  PhotoStockDependency
//
//  Created by Julia Grasevych on 19.02.2024.
//

import Foundation
import Combine
import Core

public struct Photo {
    public let url: URL
    public let author: String
    
    public init(url: URL, author: String) {
        self.url = url
        self.author = author
    }
}

public protocol PhotoStockFetching {
    func photo(for location: LocationProtocol, tags: [String]) async throws -> Photo
}

public protocol PhotoStockFetchingReactive {
    func photo(for location: LocationProtocol, tags: [String]) -> AnyPublisher<Photo, Error>
}
