//
//  PhotoStockFetching.swift
//  PhotoStockDependency
//
//  Created by Julia Grasevych on 19.02.2024.
//

import Foundation
import Core

public protocol PhotoStockFetching {
    func photoURL(for location: LocationProtocol, tags: [String]) async throws -> URL
}
