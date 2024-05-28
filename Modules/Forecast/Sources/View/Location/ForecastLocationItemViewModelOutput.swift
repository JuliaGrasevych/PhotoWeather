//
//  ForecastLocationItemViewModelOutput.swift
//  Forecast
//
//  Created by Julia Grasevych on 19.03.2024.
//

import Foundation
import ForecastDependency

@MainActor
class ForecastLocationItemViewModelOutput: ObservableObject {
    @Published var locationName: String = ""
    @Published var isUserLocation: Bool = false
    @Published var currentWeather: CurrentWeather = .default
    @Published var todayForecast: TodayForecast = .default
    @Published var hourlyForecast: [HourlyForecast] = [.default]
    @Published var dailyForecast: [DailyForecast] = [.default]
    @Published var image: LocationPhoto?
    @Published var imageAuthorTitle: String?
    @Published var error: Error?
}

extension ForecastLocationItemViewModelOutput {
    struct CurrentWeather {
        let temperature: String
        let weatherSFSymbol: String
        let weatherDescription: String
    }
    struct TodayForecast {
        let temperatureMin: String
        let temperatureMax: String
    }
    struct HourlyForecast {
        let time: String
        let temperature: String
        let weatherSFSymbol: String
    }
    struct DailyForecast {
        let date: String
        let temperatureMin: String
        let temperatureMax: String
        let weatherSFSymbol: String
    }
    
    enum Error: LocalizedError {
        case deleteFailed(any ForecastLocation)
        
        var errorDescription: String? {
            switch self {
            case .deleteFailed(let location):
                return "Failed to delete the location \(location.name)"
            }
        }
    }
}
