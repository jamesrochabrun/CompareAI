//
//  MarkdownUI+Theme.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/21/24.
//

import Foundation
import MarkdownUI
import SwiftUI

extension MarkdownUI.Theme {

  /// Creates a custom MarkdownUI theme with specified font size. Optionally allows code to wrap within the proposed width.
  /// - Parameters:
  ///   - fontSize: The font size to be applied to non-code text elements.
  ///   - wrapCode: Determines if code blocks should wrap text to fit within the container's width. Defaults to `false`, meaning code will not wrap and will be scrollable horizontally instead.
  /// - Returns: A `MarkdownUI.Theme` configured with the specified settings.
  static func custom(
    fontSize: Double,
    colorScheme: ColorScheme,
    wrapCode: Bool = true)
    -> MarkdownUI.Theme
  {
    .gitHub.text {
      // To be applied to NON Code ONLY.
      ForegroundColor(.primary)
      BackgroundColor(Color.clear)
      FontSize(fontSize)
      FontWeight(.medium)
    }
    .paragraph { configuration in
      // To be applied to the NON Code ONLY.
      configuration.label
        .relativeLineSpacing(.em(0.6))
    }
    .codeBlock { configuration in
      // To be applied to Code ONLY.
      if wrapCode {
        configuration.label
          // Allows code to extend to the full width of the proposed size.
          .frame(maxWidth: .infinity, alignment: .leading)
          .codeBlockLabelStyle()
          .codeBlockStyle(colorScheme: colorScheme, configuration)
      } else {
        ScrollView(.horizontal) {
          configuration.label
            .codeBlockLabelStyle()
        }
        .workaroundForVerticalScrollingBugInMacOS()
        .codeBlockStyle(colorScheme: colorScheme, configuration)
      }
    }
  }
}

/// To be applied to code block ONLY.
extension View {

  func codeBlockLabelStyle() -> some View {
    relativeLineSpacing(.em(0.225))
      .markdownTextStyle {
        FontFamilyVariant(.monospaced)
        FontSize(.em(0.85))
      }
      .padding(24)
      // Extra padding for code block.
      .padding(.top, 18)
  }

  func codeBlockStyle(
    colorScheme: ColorScheme,
    _ configuration: CodeBlockConfiguration)
    -> some View
  {
    background(Colors.codeBlockBackgroundColor())
      .overlay(alignment: .top) {
        HStack(alignment: .center) {
          Text(configuration.language ?? "code")
            .foregroundStyle(.primary)
            .font(.callout)
            .padding(8)
            .lineLimit(1)
          Spacer()
          CopyToClipboardButton(textToCopy: configuration.content)
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
        }
        .background(Colors.codeBlockHeaderBackgroundColor(colorScheme))
      }
      .clipShape(RoundedRectangle(cornerRadius: 6))
      .markdownMargin(top: 16, bottom: 16)
      .overlay(
        RoundedRectangle(cornerRadius: 6)
          .stroke(Colors.codeBlockBorderColor(colorScheme), lineWidth: 0.75))
  }
}

extension View {

  /// https://stackoverflow.com/questions/64920744/swiftui-nested-scrollviews-problem-on-macos
  @ViewBuilder
  func workaroundForVerticalScrollingBugInMacOS() -> some View {
    VerticalScrollingFixWrapper { self }
  }
}

// MARK: - VerticalScrollingFixWrapper

struct VerticalScrollingFixWrapper<Content>: View where Content: View {
  let content: () -> Content

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  var body: some View {
    VerticalScrollingFixViewRepresentable(content: content())
  }
}

// MARK: - VerticalScrollingFixViewRepresentable

struct VerticalScrollingFixViewRepresentable<Content>: NSViewRepresentable where Content: View {

  let content: Content

  func makeNSView(context _: Context) -> NSHostingView<Content> {
    VerticalScrollingFixHostingView<Content>(rootView: content)
  }

  func updateNSView(_: NSHostingView<Content>, context _: Context) { }
}

// MARK: - VerticalScrollingFixHostingView

final class VerticalScrollingFixHostingView<Content>: NSHostingView<Content> where Content: View {
  override func wantsForwardedScrollEvents(for axis: NSEvent.GestureAxis) -> Bool {
    axis == .vertical
  }
}
