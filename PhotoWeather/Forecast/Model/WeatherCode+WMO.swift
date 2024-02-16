//
//  Weather+WMO.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 08.02.2024.
//

import Foundation

extension ForecastItem.WeatherCode {
    public var description: String {
        switch self {
            case 0:
                return "Clear sky"
            case 1:
                return "Mainly clear"
            case 2:
                return "Partly cloudy"
            case 3:
                return "Overcast"
            case 45:
                return "Fog"
            case 48:
                return "Depositing rime fog"
            case 51:
                return "Drizzle: Light intensity"
            case 53:
                return "Drizzle: Moderate intensity"
            case 55:
                return "Drizzle: Dense intensity"
            case 56:
                return "Freezing Drizzle: Light intensity"
            case 57:
                return "Freezing Drizzle: Dense intensity"
            case 61:
                return "Rain: Slight intensity"
            case 63:
                return "Rain: Moderate intensity"
            case 65:
                return "Rain: Heavy intensity"
            case 66:
                return "Freezing Rain: Light intensity"
            case 67:
                return "Freezing Rain: Heavy intensity"
            case 71:
                return "Snow fall: Slight intensity"
            case 73:
                return "Snow fall: Moderate intensity"
            case 75:
                return "Snow fall: Heavy intensity"
            case 77:
                return "Snow grains"
            case 80:
                return "Rain showers: Slight intensity"
            case 81:
                return "Rain showers: Moderate intensity"
            case 82:
                return "Rain showers: Violent intensity"
            case 85:
                return "Snow showers: Slight intensity"
            case 86:
                return "Snow showers: Heavy intensity"
            case 95:
                return "Thunderstorm: Slight or moderate"
            case 96:
                return "Thunderstorm with slight hail"
            case 99:
                return "Thunderstorm with heavy hail"
            default:
                return "n/a"
            }
    }
    /// Weather icon Unicode symbol to be used with `weather-icons-lite` font.
    /// Always represents day
    public var icon: String {
        iconDay
    }
    
    /// Weather icon Unicode symbol to be used with `weather-icons-lite` font.
    /// Always represents day
    public var iconDay: String {
        switch self {
        case 0:
            // "Clear sky"
            return "\u{f00d}"
        case 1:
            // "Mainly clear"
            return "\u{f00c}"
        case 2:
            // "Partly cloudy"
            return "\u{f002}"
        case 3:
            // "Overcast"
            return "\u{f013}"
        case 45, 48:
            // "Fog and depositing rime fog"
            return "\u{f014}"
        case 51, 53, 55, 56, 57:
            // "Drizzle: Light, moderate, and dense intensity"
            // "Freezing Drizzle: Light and dense intensity"
            return "\u{f01a}"
        case 61, 63, 65, 66, 67, 80, 81, 82:
            // "Rain: Slight, moderate and heavy intensity"
            // "Freezing Rain: Light and heavy intensity"
            // "Rain showers: Slight, moderate, and violent"
            return "\u{f019}"
        case 71, 73, 75, 77, 85, 86:
            // "Snow fall: Slight, moderate, and heavy intensity"
            // "Snow grains"
            // "Snow showers slight and heavy"
            return "\u{f01b}"
        case 95, 96, 99:
            // "Thunderstorm: Slight or moderate"
            // "Thunderstorm with slight and heavy hail"
            return "\u{f01e}"
        default:
            return "n/a"
        }
    }
    
    /// Weather icon Unicode symbol to be used with `weather-icons-lite` font.
    /// Always represents night
    public var iconNight: String {
        switch self {
        case 0:
            // "Clear sky"
            return "\u{f02e}"
        case 1:
            // "Mainly clear"
            return "\u{f081}"
        case 2:
            // "Partly cloudy"
            return "\u{f086}"
        case 3:
            // "Overcast"
            return "\u{f013}"
        case 45, 48:
            // "Fog and depositing rime fog"
            return "\u{f014}"
        case 51, 53, 55, 56, 57:
            // "Drizzle: Light, moderate, and dense intensity"
            // "Freezing Drizzle: Light and dense intensity"
            return "\u{f01a}"
        case 61, 63, 65, 66, 67, 80, 81, 82:
            // "Rain: Slight, moderate and heavy intensity"
            // "Freezing Rain: Light and heavy intensity"
            // "Rain showers: Slight, moderate, and violent"
            return "\u{f028}"
        case 71, 73, 75, 77, 85, 86:
            // "Snow fall: Slight, moderate, and heavy intensity"
            // "Snow grains"
            // "Snow showers slight and heavy"
            return "\u{f02a}"
        case 95, 96, 99:
            // "Thunderstorm: Slight or moderate"
            // "Thunderstorm with slight and heavy hail"
            return "\u{f02d}"
        default:
            return "n/a"
        }
    }
}

// MARK: - Formating
protocol DayDependentForecast {
    var isDay: Bool { get }
    var weatherCode: ForecastItem.WeatherCode { get }
}

extension ForecastItem.CurrentWeather: DayDependentForecast { }

extension ForecastItem.HourlyWeather: DayDependentForecast { }

struct WeatherIconFormatStyle: FormatStyle {
    public typealias FormatInput = DayDependentForecast
    public typealias FormatOutput = String
    
    public func format(_ value: any DayDependentForecast) -> String {
        value.isDay ? value.weatherCode.iconDay : value.weatherCode.iconNight
    }
}

extension FormatStyle where Self == WeatherIconFormatStyle {
    static var weatherIcon: WeatherIconFormatStyle {
        return WeatherIconFormatStyle()
    }
}

extension DayDependentForecast {
    func formatted<Style: FormatStyle>(_ style: Style) -> Style.FormatOutput where Style.FormatInput == DayDependentForecast {
        style.format(self)
    }
}
