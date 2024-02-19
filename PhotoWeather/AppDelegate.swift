//
//  AppDelegate.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 15.02.2024.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerProviderFactories()
        return true
    }
}
