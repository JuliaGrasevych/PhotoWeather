//
//  NamedLocation.swift
//  Forecast
//
//  Created by Julia Grasevych on 20.02.2024.
//

import Foundation

public struct NamedLocation: Identifiable {
    public typealias ID = String
    
    public let id: String
    public let name: String
    public let location: ForecastLocation
}

extension NamedLocation: Sendable { }
