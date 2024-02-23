//
//  ForecastLocation.swift
//  Forecast
//
//  Created by Julia Grasevych on 12.02.2024.
//

import Foundation
import Core

public protocol ForecastLocation: LocationProtocol, Sendable {
    var timeZoneIdentifier: String? { get }
}

public enum Season: String {
    case spring
    case summer
    case autumn
    case winter
    
    public var tag: String { rawValue }
}

extension ForecastLocation {
    func season(for date: Date, calendar: Calendar) throws -> Season {
        let isNorth = latitude > 0
        return try calendar.season(for: date, isNorth: isNorth)
    }
}

extension Calendar {
    public enum DateError: Error {
        case invalidDate
    }
}

extension Calendar {
    func season(for date: Date, isNorth: Bool) throws -> Season {
        let dateComponents = dateComponents([.month], from: date)
        guard let month = dateComponents.month else {
            throw Calendar.DateError.invalidDate
        }
        return try Self.season(for: month, isNorth: isNorth)
    }
    
    static func season(for month: Int, isNorth: Bool) throws -> Season {
        switch (month, isNorth) {
        case (1...2, true),
            (12, true),
            (6...8, false):
            return .winter
        case (3...5, true),
            (9...11, false):
            return .spring
        case (6...8, true),
            (1...2, false),
            (12, false):
            return .summer
        case (9...11, true),
            (3...5, false):
            return .autumn
        default:
            throw Calendar.DateError.invalidDate
        }
    }
}
