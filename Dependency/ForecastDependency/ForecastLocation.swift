//
//  ForecastLocation.swift
//  ForecastDependency
//
//  Created by Julia Grasevych on 27.02.2024.
//

import Foundation
import Core

public protocol ForecastLocation: LocationProtocol, Equatable, Identifiable where ID == String {
    var id: String { get }
    var name: String { get }
    var isUserLocation: Bool { get }
    var timeZoneIdentifier: String? { get }
}

public extension ForecastLocation {
    var photoTags: [String] {
        let calendar = (try? Calendar.currentCalendar(for: self)) ?? Calendar.current
        guard let tag = try? season(for: Date.now, calendar: calendar).tag else {
            return []
        }
        return [tag]
    }
}
