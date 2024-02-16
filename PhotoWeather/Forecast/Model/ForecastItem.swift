//
//  ForecastItem.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 05.02.2024.
//

import Foundation

public struct ForecastItem: Codable {
    private enum CodingKeys: String, CodingKey {
        case current
        case currentUnits = "current_units"
        case daily
        case dailyUnits = "daily_units"
        case hourly
        case hourlyUnits = "hourly_units"
        
    }
    public let current: CurrentWeather
    public let currentUnits: CurrentUnits
    public let hourly: HourlyForecast
    public let hourlyUnits: HourlyUnits
    public let daily: DailyForecast
    public let dailyUnits: DailyUnits
}

extension ForecastItem {
    public typealias WeatherCode = Int
}

extension ForecastItem {
    public struct CurrentUnits: Codable {
        private enum CodingKeys: String, CodingKey {
            case temperature = "temperature_2m"
        }
        public let temperature: String
    }
}

extension ForecastItem {
    public struct CurrentWeather: Codable {
       private enum CodingKeys: String, CodingKey {
           case time
           case temperature = "temperature_2m"
           case weatherCode = "weather_code"
           case isDay = "is_day"
        }
        public let time: Date
        public let temperature: Double
        public let weatherCode: WeatherCode
        @BoolIntDecodable
        public var isDay: Bool
    }
}

extension ForecastItem {
    public struct HourlyUnits: Codable {
        private enum CodingKeys: String, CodingKey {
            case temperature = "temperature_2m"
        }
        public let temperature: String
    }
}

extension ForecastItem {
    public struct HourlyWeather {
        public let time: Date
        public let weatherCode: WeatherCode
        public let temperature: Double
        public let isDay: Bool
    }
    
    public struct HourlyForecast: Codable {
        private enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperature = "temperature_2m"
            case isDay = "is_day"
        }
        
        private let time: [Date]
        private let weatherCode: [WeatherCode]
        private let temperature: [Double]
        private var isDay: [BoolIntDecodable]
        
        public var weather: [HourlyWeather] {
            zip(time, zip(weatherCode, zip(temperature, isDay)))
                .map { args in
                    let (time, (code, (tmp, isDay))) = args
                    return HourlyWeather(
                        time: time,
                        weatherCode: code,
                        temperature: tmp,
                        isDay: isDay.wrappedValue
                    )
                }
        }
    }
}

extension ForecastItem {
    public struct DailyUnits: Codable {
        private enum CodingKeys: String, CodingKey {
            case temperatureMax = "temperature_2m_max"
            case temperatureMin = "temperature_2m_min"
        }
        public let temperatureMax: String
        public let temperatureMin: String
    }
}

extension ForecastItem {
    public struct DailyWeather {
        public let time: Date
        public let weatherCode: WeatherCode
        public let temperatureMax: Double
        public let temperatureMin: Double
    }
    
    public struct DailyForecast: Codable {
        private enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperatureMax = "temperature_2m_max"
            case temperatureMin = "temperature_2m_min"
        }
        
        private let time: [Date]
        private let weatherCode: [WeatherCode]
        private let temperatureMax: [Double]
        private let temperatureMin: [Double]
        
        public var weather: [DailyWeather] {
            zip(time, zip(weatherCode, zip(temperatureMax, temperatureMin)))
                .map { args in
                    let (time, (code, (tmpMax, tmpMin))) = args
                    return DailyWeather(
                        time: time,
                        weatherCode: code,
                        temperatureMax: tmpMax,
                        temperatureMin: tmpMin
                    )
                }
        }
    }
}

/// Preview
extension ForecastItem.CurrentUnits {
    static let preview: ForecastItem.CurrentUnits = ForecastItem.CurrentUnits(temperature: "ºC")
}
extension ForecastItem.CurrentWeather {
    static let preview: ForecastItem.CurrentWeather = ForecastItem.CurrentWeather(
        time: .now,
        temperature: 0,
        weatherCode: 0, 
        isDay: true
    )
}
extension ForecastItem.HourlyUnits {
    static let preview: ForecastItem.HourlyUnits = ForecastItem.HourlyUnits(temperature: "ºC")
}
extension ForecastItem.HourlyForecast {
    static let preview: ForecastItem.HourlyForecast = ForecastItem.HourlyForecast(
        time: [.now],
        weatherCode: [0],
        temperature: [0],
        isDay: [BoolIntDecodable(wrappedValue: true)]
    )
}
extension ForecastItem.DailyUnits {
    static let preview: ForecastItem.DailyUnits = ForecastItem.DailyUnits(
        temperatureMax: "ºC",
        temperatureMin: "ºC"
    )
}
extension ForecastItem.DailyForecast {
    static let preview: ForecastItem.DailyForecast = ForecastItem.DailyForecast(
        time: [.now],
        weatherCode: [0],
        temperatureMax: [0],
        temperatureMin: [0]
    )
}
extension ForecastItem {
    static let preview: ForecastItem = ForecastItem(
        current: .preview,
        currentUnits: .preview,
        hourly: .preview,
        hourlyUnits: .preview,
        daily: .preview,
        dailyUnits: .preview
    )
}
