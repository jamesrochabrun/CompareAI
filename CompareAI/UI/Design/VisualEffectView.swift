//
//  VisualEffectView.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/30/24.
//

import SwiftUI

extension View {
  public func backgroundGaussianBlur(type: NSVisualEffectView.BlendingMode = .withinWindow) -> some View {
    background(VisualEffectView(type: type))
  }
}

// MARK: - VisualEffectView

/// Applies a visual background effect similar to the ChatGPT macOS app.
public struct VisualEffectView: NSViewRepresentable {
  let type: NSVisualEffectView.BlendingMode

  public init(type: NSVisualEffectView.BlendingMode = .withinWindow) {
    self.type = type
  }

  public func makeNSView(context _: Context) -> NSVisualEffectView {
    NSVisualEffectView()
  }

  public func updateNSView(_ nsView: NSVisualEffectView, context _: Context) {
    nsView.blendingMode = type
    nsView.material = .popover
  }
}
