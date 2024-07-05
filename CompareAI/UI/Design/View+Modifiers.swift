//
//  View+Modifiers.swift
//  CompareAI
//
//  Created by James Rochabrun on 7/5/24.
//

import Foundation
import SwiftUI

extension View {
   
   func card(
      border: Color,
      cornerRadius: CGFloat,
      lineWidth: CGFloat = 0.75)
      -> some View
   {
      self
         .cornerRadius(cornerRadius)
         .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
         .overlay(
           RoundedRectangle(cornerRadius: cornerRadius)
             .stroke(border, lineWidth: lineWidth))
         .shadow(color: border.opacity(0.04), radius: 5, x: 0, y: 2)
   }
}

struct GradientBackgroundModifier: ViewModifier {
    var colors: [Color]
    var startPoint: UnitPoint
    var endPoint: UnitPoint
    
    func body(content: Content) -> some View {
        content
            .background(LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint))
    }
}

extension View {
    func gradientBackground(colors: [Color], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) -> some View {
        self.modifier(GradientBackgroundModifier(colors: colors, startPoint: startPoint, endPoint: endPoint))
    }
}
 
