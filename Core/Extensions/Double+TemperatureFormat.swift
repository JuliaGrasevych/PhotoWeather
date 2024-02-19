//
//  Double+TemperatureFormat.swift
//  Core
//
//  Created by Julia Grasevych on 15.02.2024.
//

import Foundation

public struct TemperatureFormatStyle: FormatStyle {
    public typealias FormatInput = Double
    public typealias FormatOutput = String
    
    static let numberFormatStyle = FloatingPointFormatStyle<FormatInput>
        .number
        .precision(.fractionLength(.zero))
        .rounded(rule: .toNearestOrAwayFromZero)
    
    public func format(_ value: Double) -> String {
        let formattedNumber = value.formatted(Self.numberFormatStyle)
        switch value {
        case 0:
            return formattedNumber
        case ..<0:
            return formattedNumber
        case 0...:
            return "+\(formattedNumber)"
        default:
            return formattedNumber
        }
    }
}

extension FormatStyle where Self == TemperatureFormatStyle {
    public static var temperature: TemperatureFormatStyle {
        return TemperatureFormatStyle()
    }
}
