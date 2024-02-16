//
//  Dependencies.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 07.02.2024.
//

import Foundation
import SwiftUI

enum Dependencies {
    static var networkService: NetworkServiceProtocol {
        NetworkService()
    }
    
    static var forecastFetcher: ForecastFetching {
        ForecastFetcher(networkService: networkService)
    }
    
    static var configProvider: ConfigProviding {
        ConfigProvider()
    }
    
    static var photoFetcher: PhotoStockFetching {
        PhotoStockFetcher(networkService: networkService, apiKeyProvider: configProvider)
    }
}

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
