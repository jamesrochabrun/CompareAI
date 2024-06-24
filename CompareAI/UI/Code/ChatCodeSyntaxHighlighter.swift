//
//  ChatCodeSyntaxHighlighter.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/21/24.
//

import Foundation
import Highlightr
import MarkdownUI
import SwiftUI

// MARK: - ChatCodeSyntaxHighlighter

/// CodeSyntaxHighlighter: A type that provides syntax highlighting to code blocks in a Markdown view.
///
/// To configure the current code syntax highlighter for a view hierarchy, use the
/// `markdownCodeSyntaxHighlighter(_:)` modifier.
final class ChatCodeSyntaxHighlighter: CodeSyntaxHighlighter {

  // MARK: Internal

  /// CodeSyntaxHighlighter protocol required function
  func highlightCode(_ content: String, language: String?) -> Text {
    let content = highlightedCodeBlock(
      code: content,
      language: language ?? "")
    return Text(AttributedString(content))
  }

  func updateTheme(colorScheme: ColorScheme) {
    lightMode = colorScheme == .light
    highlighter?.setTheme(to: lightMode ? "xcode" : "atom-one-dark")
  }

  // MARK: Private

  private var lightMode = false
  private let highlighter = Highlightr()
  private let chatCodeFontSize = 13.0

  /// Reference: https://github.com/intitni/CopilotForXcode/blob/main/Tool/Sources/SharedUIComponents/SyntaxHighlighting.swift
  private func highlightedCodeBlock(
    code: String,
    language: String)
    -> NSAttributedString
  {
    var language = language
    // Workaround: Highlightr uses a different identifier for Objective-C.
    if language.lowercased().hasPrefix("objective"), language.lowercased().hasSuffix("c") {
      language = "objectivec"
    }
    func unhighlightedCode() -> NSAttributedString {
      NSAttributedString(
        string: code,
        attributes: [
          .foregroundColor: lightMode ? NSColor.black : NSColor.white,
          .font: NSFont.monospacedSystemFont(ofSize: chatCodeFontSize, weight: .regular),
        ])
    }
    guard let highlighter else {
      return unhighlightedCode()
    }
    highlighter.theme.setCodeFont(.monospacedSystemFont(ofSize: chatCodeFontSize, weight: .regular))

    guard let formatted = highlighter.highlight(code, as: language) else {
      return unhighlightedCode()
    }
    if formatted.string == "undefined" {
      return unhighlightedCode()
    }
    return formatted
  }

}

// MARK: - CodeSyntaxHighlight

/// We use the `ChatCodeSyntaxHighlighter` as an environment object to inject it into a `ChatMessageView`.
/// This approach improves performance by injecting the highlighter instead of recreating it for each chat message view.
/// Internally, we instantiate a `Highlightr` object, which is a utility class for generating a highlighted `NSAttributedString` from a `String`.
///
/// `ChatCodeSyntaxHighlighter` conforms to `CodeSyntaxHighlighter`, a protocol from the Swift Markdown package.
///
/// `CodeSyntaxHighlighter`:
/// - A type that provides syntax highlighting to code blocks in a Markdown view.
/// - To configure the current code syntax highlighter for a view hierarchy, use the
/// `markdownCodeSyntaxHighlighter(_:)` modifier.
private struct CodeSyntaxHighlight: EnvironmentKey {
  static let defaultValue = ChatCodeSyntaxHighlighter()
}

extension EnvironmentValues {
  var codeSyntaxHighlighter: ChatCodeSyntaxHighlighter {
    get { self[CodeSyntaxHighlight.self] }
    set { self[CodeSyntaxHighlight.self] = newValue }
  }
}
