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
    
    public init(color: Color) {
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        content.shadow(color: color, radius: 10)
    }
}

public extension View {
    func whiteContentShadow() -> some View {
        modifier(ContentShadow(color: .white))
    }
}
