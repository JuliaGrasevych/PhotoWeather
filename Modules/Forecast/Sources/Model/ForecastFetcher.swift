//
//  ForecastFetcher.swift
//  Forecast
//
//  Created by Julia Grasevych on 05.02.2024.
//

import Foundation
import Combine
import Core
import ForecastDependency

public protocol ForecastFetching {
    func forecast(for location: any ForecastLocation) async throws -> ForecastItem
}

public protocol ForecastFetchingReactive {
    func forecast(for location: any ForecastLocation) -> AnyPublisher<ForecastItem, Error>
}

class ForecastFetcher: ForecastFetching {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func forecast(for location: any ForecastLocation) async throws -> ForecastItem {
        let url = Self.fetchURL(for: location)
        return try await networkService.requestData(for: url)
    }
    
    // MARK: - Requests
    private static func fetchURL(for location: any ForecastLocation) -> URL? {
        let queryItems = [
            QueryItemKeys.latitude: "\(location.latitude)",
            QueryItemKeys.longitude: "\(location.longitude)",
            QueryItemKeys.current: "temperature_2m,weather_code,is_day",
            QueryItemKeys.hourly: "temperature_2m,weather_code,is_day",
            QueryItemKeys.forecastHours: "6",
            QueryItemKeys.daily: "weather_code,temperature_2m_max,temperature_2m_min",
            QueryItemKeys.timezone: location.timeZoneIdentifier
        ]
            .compactMapValues { $0 }
            .map(URLQueryItem.init)
        return Endpoint.openMeteoForecast(with: queryItems).url
    }
}

extension ForecastFetcher: ForecastFetchingReactive {
    func forecast(for location: any ForecastLocation) -> AnyPublisher<ForecastItem, Error> {
        let url = Self.fetchURL(for: location)
        return networkService.requestDataPublisher(for: url)
    }
}

extension ForecastFetcher {
    private enum QueryItemKeys: String {
        case latitude
        case longitude
        case current
        case hourly
        case forecastHours = "forecast_hours"
        case daily
        case timezone
    }
}

extension Endpoint {
    static func openMeteoForecast(with queryItems: [URLQueryItem]) -> Endpoint {
        Endpoint(
            host: "api.open-meteo.com",
            path: "/v1/forecast",
            queryItems: queryItems
        )
    }
}
