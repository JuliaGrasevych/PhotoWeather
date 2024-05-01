//
//  ContentShadow.swift
//  Core
//
//  Created by Julia Grasevych on 08.03.2024.
//

import Foundation
import SwiftUI

public struct ContentShadow: ViewModifier {
    public let color: Color
    public let radius: CGFloat
    
    public init(color: Color, radius: CGFloat) {
        self.color = color
        self.radius = radius
    }
    
    public func body(content: Content) -> some View {
        content.shadow(color: color, radius: radius)
    }
}

public extension View {
    func whiteContentShadow(radius: CGFloat = 10) -> some View {
        modifier(ContentShadow(color: .white, radius: radius))
    }
    
    func defaultContentStyle() -> some View {
        self
            .foregroundStyle(.black)
            .whiteContentShadow()
    }
}
