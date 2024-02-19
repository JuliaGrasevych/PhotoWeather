//
//  ConfigProvider.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 16.02.2024.
//

import Foundation

import PhotoStock

public protocol ConfigProviding: FlickrAPIKeyProviding { }

public enum ConfigError: Error {
    case missingKey
    case invalidValue
}

struct ConfigProvider: ConfigProviding {
    enum Key: String, CustomStringConvertible {
        case flickrAPI = "FLICKR_API_KEY"
        
        var description: String {
            rawValue
        }
    }
    
    func flickrAPIKey() throws -> String {
        try Self.value(for: Key.flickrAPI.description)
    }
    
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw ConfigError.missingKey
        }
        
        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else {
                throw ConfigError.invalidValue
            }
            return value
        default:
            throw ConfigError.invalidValue
        }
    }
}
