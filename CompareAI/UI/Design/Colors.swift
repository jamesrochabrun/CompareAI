//
//  Colors.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/21/24.
//

import SwiftUI

enum Colors {

  static let defaultTintColorLightMode = Color(red: 0 / 255, green: 127 / 255, blue: 173 / 255)
  static let defaultTintColorDarkMode = Color.blue

  static func chatMessageBackgroundColor() -> Color {
    .clear
  }

  static func chatBackgroundColor(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color(red: 39 / 255, green: 39 / 255, blue: 38 / 255, opacity: 0.8) : .white.opacity(0.8)
  }

  static func codeBlockHeaderBackgroundColor(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark
      ? Color(red: 50 / 255, green: 50 / 255, blue: 50 / 255)
      : Color(
        red: 244 / 255,
        green: 242 / 255,
        blue: 240 / 255,
        opacity: 0.9)
  }

  static func codeBlockBackgroundColor() -> Color {
    .clear
  }

  static func codeBlockBorderColor(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.3)
  }

  static func tintColor() -> Color {
    .black
  }

  static func invocationTintColor(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? .orange : .black
  }

  static func tagViewBackgroundColor(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? .gray.opacity(0.3) : .gray.opacity(0.2)
  }

  static func tagViewForegroundColor(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? .blue : defaultTintColorLightMode
  }

  static func plainButtonColor(_ colorScheme: ColorScheme, isHovering: Bool) -> Color {
    if isHovering {
      colorScheme == .dark ? .white : .black
    } else {
      colorScheme == .dark ? Color.gray.opacity(0.9) : .gray
    }
  }

  static func textAreaBorderColor(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? .gray.opacity(0.5) : .gray.opacity(0.3)
  }
}
