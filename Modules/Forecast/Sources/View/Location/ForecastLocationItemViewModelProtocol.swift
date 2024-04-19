//
//  ForecastLocationItemViewModelProtocol.swift
//  Forecast
//
//  Created by Julia Grasevych on 21.03.2024.
//

import Foundation

import ForecastDependency

protocol ForecastLocationItemViewModelProtocol: ObservableObject {
    var output: ForecastLocationItemViewModelOutput { get }
    func onLoad()
    func deleteLocation()
    func refresh() async
}

extension ForecastLocationItemViewModelProtocol {
    static func todayForecast(with forecast: ForecastItem?, location: any ForecastLocation) -> ForecastLocationItemViewModelOutput.TodayForecast {
        let calendar = (try? Calendar.currentCalendar(for: location)) ?? Calendar.current
        guard let forecast,
              let today = forecast.daily
            .weather
            .first(where: { item in
                calendar.isDateInToday(item.time)
            })
        else { return .default }
        
        let tempMin = today.temperatureMin.formatted(.temperature)
        + forecast.dailyUnits.temperatureMin
        let tempMax = today.temperatureMax.formatted(.temperature)
        + forecast.dailyUnits.temperatureMax
        
        return .init(
            temperatureMin: tempMin,
            temperatureMax: tempMax
        )
    }
    
    static func hourlyForecast(with forecast: ForecastItem?) -> [ForecastLocationItemViewModelOutput.HourlyForecast] {
        guard let forecast, !forecast.hourly.weather.isEmpty else { return [.default] }
        let temperatureUnit = forecast.hourlyUnits.temperature
        return forecast.hourly.weather
            .map { item in
                ForecastLocationItemViewModelOutput.HourlyForecast(
                    time: item.time.formatted(date: .omitted, time: .shortened),
                    temperature: item.temperature.formatted(.temperature) + temperatureUnit,
                    weatherIcon: item.formatted(.weatherIcon)
                )
            }
    }
    
    static func dailyForecast(with forecast: ForecastItem?) -> [ForecastLocationItemViewModelOutput.DailyForecast] {
        guard let forecast, !forecast.daily.weather.isEmpty else { return [.default] }
        let temperatureUnits = forecast.dailyUnits
        return forecast.daily.weather
            .map { item in
                ForecastLocationItemViewModelOutput.DailyForecast(
                    date: item.time.formatted(Date.FormatStyle().day().month()),
                    temperatureMin: item.temperatureMin.formatted(.temperature) + temperatureUnits.temperatureMin,
                    temperatureMax: item.temperatureMax.formatted(.temperature) + temperatureUnits.temperatureMax,
                    weatherIcon: item.weatherCode.icon
                )
            }
    }
}
