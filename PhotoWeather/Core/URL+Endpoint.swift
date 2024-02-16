//
//  URL+Endpoint.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 14.02.2024.
//

import Foundation

public struct Endpoint {
    public let scheme: String
    public let host: String
    public let path: String
    public let queryItems: [URLQueryItem]
    
    public init(
        scheme: String = "https",
        host: String,
        path: String = "/",
        queryItems: [URLQueryItem] = []
    ) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.queryItems = queryItems
    }
}

public extension Endpoint {
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
}
