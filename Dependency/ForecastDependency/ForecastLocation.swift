//
//  ForecastLocation.swift
//  ForecastDependency
//
//  Created by Julia Grasevych on 27.02.2024.
//

import Foundation
import Core

public protocol ForecastLocation: LocationProtocol, Identifiable where ID == String {
    var name: String { get }
    var timeZoneIdentifier: String? { get }
}
