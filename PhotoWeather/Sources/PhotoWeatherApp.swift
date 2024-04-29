//
//  PhotoWeatherApp.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 05.02.2024.
//

import SwiftUI
import ForecastDependency

@main
final class PhotoWeatherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    lazy var rootComponent = RootComponent(configuration: .init(storage: .swiftData))
//    lazy var rootComponent = RootReactiveComponent(configuration: .init(storage: .swiftData))
    
    var body: some Scene {
        return WindowGroup {
            rootComponent.rootView
        }
    }
}
