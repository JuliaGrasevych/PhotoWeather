//
//  NetworkService.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 16.02.2024.
//

import Foundation
import Combine
import Core

struct NetworkService: NetworkServiceProtocol {
    var decoder: JSONDecoder = JSONDecoder().forecast()
    
    func requestData<DataType: Decodable>(for url: URL?, transform: (Data) throws -> Data) async throws -> DataType {
        guard let url else {
            throw NetworkError.invalidURLComponents
        }
        let request = URLRequest(url: url)
        let response = try await URLSession.shared.data(for: request)
        let transformedData = try transform(response.0)
        let item = try decoder.decode(DataType.self, from: transformedData)
        return item
    }
    
    func requestDataPublisher<DataType: Decodable>(for url: URL?, transform: @escaping (Data) throws -> Data) -> AnyPublisher<DataType, Error> {
        guard let url else {
            return Fail(error: NetworkError.invalidURLComponents)
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { response in
                try transform(response.data)
            }
            .decode(type: DataType.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}

public extension JSONDecoder {
    func forecast() -> Self {
        let fullDateFormatter = DateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm")
        let dayDateFormatter = DateFormatter(dateFormat: "yyyy-MM-dd")
        self.dateDecodingStrategy = .anyFormatter(in: [fullDateFormatter, dayDateFormatter])
        return self
    }
}
