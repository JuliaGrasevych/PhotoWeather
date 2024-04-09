//
//  PhotoStockFetcher.swift
//  PhotoStock
//
//  Created by Julia Grasevych on 08.02.2024.
//

import Foundation
import Combine
import Core

import PhotoStockDependency

public protocol FlickrAPIKeyProviding {
    func flickrAPIKey() throws -> String
}

public enum PhotoStockFetchingError: Error {
    case noResultsFound
}

class PhotoStockFetcher: PhotoStockFetching {
    private let networkService: NetworkServiceProtocol
    private let apiKeyProvider: FlickrAPIKeyProviding
    
    init(
        networkService: NetworkServiceProtocol,
        apiKeyProvider: FlickrAPIKeyProviding
    ) {
        self.networkService = networkService
        self.apiKeyProvider = apiKeyProvider
    }
    
    func photo(for location: LocationProtocol, tags: [String]) async throws -> Photo {
        let apiKey = try apiKeyProvider.flickrAPIKey()
        let fetchURL = Self.fetchURL(
            for: location,
            tags: tags,
            apiKey: apiKey
        )
        let data: PhotosResponse = try await networkService.requestData(
            for: fetchURL,
            transform: Self.transformResponse
        )
        guard let photo = data.photos.photo.randomElement(),
              let photoUrl = Self.photoURL(for: photo)
        else {
            throw PhotoStockFetchingError.noResultsFound
        }
        return Photo(
            url: photoUrl,
            author: photo.owner
        )
    }
    
    private static func transformResponse(data: Data) -> Data {
        guard var stringData = String(data: data, encoding: .utf8) else {
            return data
        }
        stringData.trimPrefix("jsonFlickrApi(")
        guard let lastBracket = stringData.lastIndex(of: ")") else {
            return data
        }
        let trimmedStringData = stringData.prefix(upTo: lastBracket)
        guard let trimmedData = trimmedStringData.data(using: .utf8) else {
            return data
        }
        return trimmedData
    }
    
    // MARK: - Endpoints
    private static func fetchURL(for location: LocationProtocol, tags: [String], apiKey: String) -> URL? {
        let queryItems = [
            QueryItemKeys.apiKey: apiKey,
            QueryItemKeys.tags: tags
                .map { $0.lowercased() }
                .joined(separator: ","),
            QueryItemKeys.tagMode: TagMode.any.rawValue,
            QueryItemKeys.lon: "\(location.longitude)",
            QueryItemKeys.lat: "\(location.latitude)",
            QueryItemKeys.perPage: "25",
            QueryItemKeys.format: "json",
            QueryItemKeys.method: "flickr.photos.search",
            QueryItemKeys.accuracy: "9",
            QueryItemKeys.media: "photos",
            QueryItemKeys.sort: "relevance"
        ]
            .map(URLQueryItem.init)
        
        return Endpoint.flickrServices(with: queryItems).url
    }
    
    private static func photoURL(for photoItem: PhotosResponse.PhotosData.Photo) -> URL? {
        guard let url = Endpoint.flickrStaticContent().url else {
            return nil
        }
        return photoItem.url(
            with: url,
            size: .large
        )
    }
}

extension PhotoStockFetcher: PhotoStockFetchingReactive {
    func photo(for location: any LocationProtocol, tags: [String]) -> AnyPublisher<Photo, any Error> {
        do {
            let apiKey = try apiKeyProvider.flickrAPIKey()
            let fetchURL = Self.fetchURL(
                for: location,
                tags: tags,
                apiKey: apiKey
            )
            
            let dataPublisher: AnyPublisher<PhotosResponse, Error> = networkService.requestDataPublisher(
                for: fetchURL,
                transform: Self.transformResponse
            )
            
            return dataPublisher
                .tryMap { data in
                    guard let photo = data.photos.photo.randomElement(),
                          let photoUrl = Self.photoURL(for: photo)
                    else {
                        throw PhotoStockFetchingError.noResultsFound
                    }
                    return Photo(
                        url: photoUrl,
                        author: photo.owner
                    )
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}

extension PhotoStockFetcher {
    private enum QueryItemKeys: String {
        case apiKey = "api_key"
        case tags
        case tagMode = "tag_mode"
        case lon
        case lat
        case perPage = "per_page"
        case format
        case method
        case accuracy
        case media
        case sort
    }
}

extension PhotoStockFetcher {
    private enum TagMode: String {
        case all
        case any
    }
}

extension Endpoint {
    static func flickrServices(with queryItems: [URLQueryItem]) -> Endpoint {
        Endpoint(
            host: "www.flickr.com",
            path: "/services/rest",
            queryItems: queryItems
        )
    }
}

extension Endpoint {
    static func flickrStaticContent() -> Endpoint {
        Endpoint(host: "live.staticflickr.com")
    }
}
