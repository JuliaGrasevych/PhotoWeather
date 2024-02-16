//
//  NetworkService.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 07.02.2024.
//

import Foundation

enum NetworkError: Error {
    case invalidURLComponents
}

public protocol NetworkServiceProtocol {
    var decoder: JSONDecoder { get }

    func requestData<DataType: Decodable>(for url: URL?, transform: (Data) throws -> Data) async throws -> DataType
}

public extension NetworkServiceProtocol {
    func requestData<DataType: Decodable>(for url: URL?, transform: (Data) throws -> Data) async throws -> DataType {
        guard let url else {
            throw NetworkError.invalidURLComponents
        }
        let request = URLRequest(url: url)
        let response = try await URLSession.shared.data(for: request)
        let transformedData = try transform(response.0)
        print("===transformedData = \(String(data: transformedData, encoding: .utf8))")
        let item = try decoder.decode(DataType.self, from: transformedData)
        return item
    }
    
    func requestData<DataType: Decodable>(for url: URL?) async throws -> DataType {
        try await requestData(
            for: url,
            transform: { $0 }
        )
    }
}
