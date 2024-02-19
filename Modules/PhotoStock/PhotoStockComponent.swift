//
//  PhotoStockComponent.swift
//  PhotoStock
//
//  Created by Julia Grasevych on 16.02.2024.
//

import Foundation
import NeedleFoundation
import Core

import PhotoStockDependency

public protocol PhotoStockComponentDependency: Dependency {
    var networkService: NetworkServiceProtocol { get }
    var apiKeyProvider: FlickrAPIKeyProviding { get }
}

public class PhotoStockComponent: Component<PhotoStockComponentDependency> {
    public var fetcher: PhotoStockFetching {
        PhotoStockFetcher(
            networkService: dependency.networkService,
            apiKeyProvider: dependency.apiKeyProvider
        )
    }
}
