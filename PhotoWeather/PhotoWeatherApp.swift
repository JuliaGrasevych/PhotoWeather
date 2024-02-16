//
//  PhotoWeatherApp.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 05.02.2024.
//

import SwiftUI
import SwiftData

@main
struct PhotoWeatherApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ForecastList(
                viewModel: ForecastList.ViewModel(
                    fetcher: Dependencies.forecastFetcher,
                    photoFetcher: Dependencies.photoFetcher
                )
            )
        }
    }
}
