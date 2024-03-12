//
//  NetworkService.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 16.02.2024.
//

import Foundation
import Core

struct NetworkService: NetworkServiceProtocol {
    var decoder: JSONDecoder = JSONDecoder().forecast()
}

public extension JSONDecoder {
    func forecast() -> Self {
        let fullDateFormatter = DateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm")
        let dayDateFormatter = DateFormatter(dateFormat: "yyyy-MM-dd")
        self.dateDecodingStrategy = .anyFormatter(in: [fullDateFormatter, dayDateFormatter])
        return self
    }
}
