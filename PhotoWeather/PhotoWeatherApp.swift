//
//  PhotoWeatherApp.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 05.02.2024.
//

import SwiftUI
import SwiftData

@main
final class PhotoWeatherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    lazy var rootComponent = RootComponent()
    
    var body: some Scene {
        return WindowGroup {
            rootComponent.rootView
        }
    }
}
