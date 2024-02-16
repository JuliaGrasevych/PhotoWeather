//
//  PhotoStockItem.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 12.02.2024.
//

import Foundation

public struct PhotosResponse: Codable {
    public let photos: PhotosData
}

extension PhotosResponse {
    public struct PhotosData: Codable {
        public let photo: [Photo]
    }
}

extension PhotosResponse.PhotosData {
    public struct Photo: Codable {
        enum CodingKeys: String, CodingKey {
            case id
            case owner
            case secret
            case server
            case title
        }
        
        public let id: String
        public let owner: String
        public let secret: String
        public let server: String
        public let title: String
        
        public func url(with baseURL: URL, size: Size) -> URL? {
            baseURL.appending(path: "\(server)/\(id)_\(secret)_\(size.suffix).png")
        }
    }
}

extension PhotosResponse.PhotosData.Photo {
    public enum Size: String {
        case thumbnail = "t"
        case small = "w"
        case medium = "c"
        case large = "b"
        
        var suffix: String { rawValue }
    }
}
