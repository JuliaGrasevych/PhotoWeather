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
    public var userDefaultsStorage: ExternalLocationStore {
        UserDefaultsStore(userDefaults: .standard)
    }
}
