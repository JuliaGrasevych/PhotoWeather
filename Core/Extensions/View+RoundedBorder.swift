//
//  View+RoundedBorder.swift
//  Core
//
//  Created by Julia Grasevych on 15.02.2024.
//

import SwiftUI

extension View {
    public func roundedBorder<S>(
        radius: Double,
        border: S,
        lineWidth: Double
    ) -> some View where S : ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: radius)
        return self
            .clipShape(roundedRect)
            .overlay {
                roundedRect
                    .stroke(border, lineWidth: lineWidth)
            }
    }
}
