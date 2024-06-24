//
//  ChatScrollView.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/23/24.
//

import Foundation
import SwiftUI

// MARK: - ChatScrollView

/// A scroll view that allows communication of scroll view metadata to a parent using bindings.
/// It uses different PreferenceKey types to determine content size, content offset, and scroll view height.
public struct ChatScrollView<Content>: View where Content: View {

  // MARK: Lifecycle

  public init(
    showIndicators: Bool = true,
    scrollViewContentSize: Binding<CGSize>,
    scrollViewHeight: Binding<CGFloat>,
    isScrolledAtBottom: Binding<Bool>,
    @ViewBuilder content: () -> Content)
  {
    self.showIndicators = showIndicators
    _scrollViewContentSize = scrollViewContentSize
    _scrollViewHeight = scrollViewHeight
    _isScrolledAtBottom = isScrolledAtBottom
    self.content = content()
  }

  // MARK: Public

  public var body: some View {
    GeometryReader { outsideProxy in
      ScrollView(.vertical, showsIndicators: showIndicators) {
        ZStack(alignment: .top) {
          GeometryReader { innerProxy in
            Color.clear
              .preference(
                key: ScrollOffsetPreferenceKey.self,
                value: calculateContentOffset(outsideProxy: outsideProxy, innerProxy: innerProxy))
              .preference(key: ScrollHeightPreferenceKey.self, value: outsideProxy.size.height)
          }
          VStack {
            content
              .background(GeometryReader { contentProxy in
                Color.clear.preference(key: ContentSizePreferenceKey.self, value: contentProxy.size)
              })
          }
        }
      }
      .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
        contentOffset = value
        isScrolledAtBottom = checkIfIsScrolledToBottomUsing(
          scrollViewHeight: outsideProxy.size.height,
          threshold: scrollViewBottomThreshold)
      }
      .onPreferenceChange(ContentSizePreferenceKey.self) { size in
        scrollViewContentSize = size
      }
      .onPreferenceChange(ScrollHeightPreferenceKey.self) { value in
        scrollViewHeight = value
      }
    }
  }

  // MARK: Internal

  let showIndicators: Bool
  @Binding var scrollViewContentSize: CGSize
  @Binding var scrollViewHeight: CGFloat
  @Binding var isScrolledAtBottom: Bool
  let content: Content

  // MARK: Private

  @State private var contentOffset = CGFloat.zero
  /// Used to determine the threshold for the bottom of the scroll view.
  private let scrollViewBottomThreshold = 20.0

  /// Checks if the content is scrolled to the bottom within the specified threshold.
  ///
  /// - Parameters:
  ///   - scrollViewHeight: The height of the ScrollView.
  ///   - threshold: The threshold value for determining if the content is scrolled to the bottom.
  ///
  /// - Returns: A boolean value indicating whether the content is scrolled to the bottom.
  private func checkIfIsScrolledToBottomUsing(
    scrollViewHeight: CGFloat,
    threshold: CGFloat)
    -> Bool
  {
    // Calculate the maximum offset (subtract the height of the ScrollView frame from the total content height).
    let maxOffset = scrollViewContentSize.height - scrollViewHeight
    return abs(contentOffset - maxOffset) <= threshold
  }

  private func calculateContentOffset(
    outsideProxy: GeometryProxy,
    innerProxy: GeometryProxy)
    -> CGFloat
  {
    outsideProxy.frame(in: .global).minY - innerProxy.frame(in: .global).minY
  }
}

// MARK: - ScrollOffsetPreferenceKey

private struct ScrollOffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce(value _: inout CGFloat, nextValue _: () -> CGFloat) { }
}

// MARK: - ContentSizePreferenceKey

private struct ContentSizePreferenceKey: PreferenceKey {
  static var defaultValue = CGSize.zero
  static func reduce(value _: inout CGSize, nextValue _: () -> CGSize) { }
}

// MARK: - ScrollHeightPreferenceKey

private struct ScrollHeightPreferenceKey: PreferenceKey {
  static var defaultValue = CGFloat.zero
  static func reduce(value _: inout CGFloat, nextValue _: () -> CGFloat) { }
}
