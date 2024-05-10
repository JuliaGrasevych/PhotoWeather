//
//  StorageComponent.swift
//  Storage
//
//  Created by Julia Grasevych on 27.02.2024.
//

import Foundation
import NeedleFoundation
import ForecastDependency

public class StorageComponent: Component<EmptyDependency> {
    public var userDefaultsStorage: ExternalLocationStoring {
        UserDefaultsStore(userDefaults: UserDefaults(suiteName: "group.com.julia.PhotoWeather") ?? .standard)
    }
    
    public var swiftDataStorge: ExternalLocationStoring {
        SwiftDataStore()
    }
}
