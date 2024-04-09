//
//  NetworkService.swift
//  Core
//
//  Created by Julia Grasevych on 07.02.2024.
//

import Foundation
import Combine

public enum NetworkError: Error {
    case invalidURLComponents
}

public protocol NetworkServiceProtocol {
    var decoder: JSONDecoder { get }

    func requestData<DataType: Decodable>(for url: URL?, transform: (Data) throws -> Data) async throws -> DataType
    func requestDataPublisher<DataType: Decodable>(for url: URL?, transform: @escaping (Data) throws -> Data) -> AnyPublisher<DataType, Error>
}

public extension NetworkServiceProtocol {
    func requestData<DataType: Decodable>(for url: URL?) async throws -> DataType {
        try await requestData(
            for: url,
            transform: { $0 }
        )
    }
    
    func requestData<DataType: Decodable>(for url: URL?) -> AnyPublisher<DataType, Error> {
        requestDataPublisher(
            for: url,
            transform: { $0 }
        )
    }
}
