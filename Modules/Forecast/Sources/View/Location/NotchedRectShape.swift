//
//  NotchedRectShape.swift
//  Forecast
//
//  Created by Julia Grasevych on 10.09.2024.
//

import SwiftUI

struct NotchedRectShape: Shape {
    enum NotchType {
        case fixed(radius: CGFloat)
        case relative(factor: CGFloat)
        
        func notchRadius(for rectWidth: CGFloat) -> CGFloat {
            switch self {
            case .fixed(let radius):
                return radius
            case .relative(let factor):
                return rectWidth / factor
            }
        }
    }
    let notchType: NotchType
    let visibleNotchPart: CGFloat
    
    init(notch: NotchType = .relative(factor: 3), visibleNotchPart: CGFloat = 6) {
        self.notchType = notch
        self.visibleNotchPart = visibleNotchPart
    }
    
    func path(in rect: CGRect) -> Path {
        let notchRadius: CGFloat = notchType.notchRadius(for: rect.width)
        let visibleNotch = notchRadius / visibleNotchPart
        
        let rectPath = Path(
            roundedRect: CGRect(
                x: rect.minX,
                y: rect.minY,
                width: rect.width,
                height: rect.height - visibleNotch
            ),
            cornerSize: .zero
        )
        let notchPath = Path(ellipseIn: CGRect(
            x: rect.midX - notchRadius / 2,
            y: rect.maxY - notchRadius,
            width: notchRadius,
            height: notchRadius
        ))
        
        return rectPath.union(notchPath)
    }
}
