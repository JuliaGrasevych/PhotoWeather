//
//  VerticalLabelStyle.swift
//  Core
//
//  Created by Julia Grasevych on 06.03.2024.
//

import Foundation
import SwiftUI

public struct VerticalLabelStyle: LabelStyle {
    public init() { }
    
    public func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.title
            configuration.icon
        }
    }
}
