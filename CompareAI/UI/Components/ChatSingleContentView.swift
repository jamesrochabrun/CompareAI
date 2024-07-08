//
//  ChatSingleContentView.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/21/24.
//

import Foundation
import MarkdownUI
import SwiftUI

/// Represents the view for a single provider. e.g: Anthropic.
struct ChatSingleContentView: View {
   
   let providerContent: LLMProviderContent
   let style: ChatSingleContentViewStyle
   let isScrollEnabled: Bool
   
   var scrollViewContent: some View {
      VStack(spacing: style.showProviderAsHeader ? 24 : 0) {
         if style.showProviderAsHeader {
            header
         }
         ScrollViewReader { proxy in
            ScrollView {
               markDownContent
                  .id(providerContent.id)
            }.onChange(of: providerContent.response) { _, newValue in
               proxy.scrollTo(providerContent.id, anchor: .bottom)
            }
         }
      }
      .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
      .frame(maxHeight: isExpanded ? nil : style.maxHeight, alignment: .top)
      .background(.ultraThinMaterial)
      .padding(.top, style.showProviderAsHeader ? 0 : 16)
      .card(border: Colors.codeBlockBorderColor(colorScheme), cornerRadius: 10)
      .padding(.horizontal, style.horizontalPadding ?? 0)
   }
   
   var nonScrollableContent: some View {
      VStack(alignment: .leading, spacing: style.showProviderAsHeader ? 24 : 0) {
         if style.showProviderAsHeader {
            header
         }
         markDownContent
      }
      .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
      .frame(maxHeight: isExpanded ? nil : style.maxHeight, alignment: .top)
      .background(.ultraThinMaterial)
      .padding(.top, style.showProviderAsHeader ? 0 : 16)
      .card(border: Colors.codeBlockBorderColor(colorScheme), cornerRadius: 10)
      .padding(.horizontal, style.horizontalPadding ?? 0)
      //  .id(providerContent.id) // Not needed in theory as this is not part of a scrolview here
   }
   
   var body: some View {
      if isScrollEnabled {
         scrollViewContent
      } else {
         nonScrollableContent
      }
   }
   
   private var markDownContent: some View {
      Markdown(providerContent.response)
         .fixedSize(horizontal: false, vertical: true)
         .textSelection(.enabled)
         .markdownTheme(.custom(fontSize: 14, colorScheme: colorScheme))
         .markdownCodeSyntaxHighlighter(codeSyntaxHighlighter)
         .padding(.horizontal)
         .padding(.bottom)
   }
   
   private var header: some View {
      HStack {
         Text(providerContent.provider.displayName)
            .padding(.horizontal, 8)
            .fontWeight(.semibold)
            .clipped()
            .frame(maxWidth: .infinity, alignment: style.providerHeaderAlignment)
            .frame(height: 40)
            .textSelection(.enabled)
         if style.showExpansionButton {
            Button {
               withAnimation {
                  isExpanded.toggle()
               }
            } label: {
               Image(systemName: isExpanded ? "arrow.up.right.and.arrow.down.left.circle" : "arrow.up.left.and.arrow.down.right.circle")
            }
            .buttonStyle(.plain)
            .contentTransition(.symbolEffect(.replace))
            .padding(.trailing)
         }
      }
      .font(.title3)
      .background(.ultraThickMaterial)
   }
   
   @Environment(\.colorScheme) private var colorScheme
   @Environment(\.codeSyntaxHighlighter) private var codeSyntaxHighlighter
   @State private var isExpanded: Bool = false
}

struct ChatSingleContentViewStyle {
   
   var horizontalPadding: CGFloat? = 16.0
   var showProviderAsHeader: Bool = true
   var providerHeaderAlignment: Alignment = .leading
   var showExpansionButton: Bool = false
   var maxHeight: CGFloat? = nil
}

extension ChatSingleContentViewStyle {
   
   static var defaultStyle: Self {
      ChatSingleContentViewStyle()
   }
   
   static var asPartOfMultipleContentHorizontal: Self {
      var style = defaultStyle
      style.horizontalPadding = nil
      style.showProviderAsHeader = true
      style.providerHeaderAlignment = .center
      return style
   }
   
   static var asPartOfMultipleContentVertical: Self {
      var style = defaultStyle
      style.horizontalPadding = nil
      style.showProviderAsHeader = true
      style.providerHeaderAlignment = .leading
      style.showExpansionButton = true
      style.maxHeight = 200
      return style
   }
   
   static var analyzing: Self {
      var style = asPartOfMultipleContentHorizontal
      style.showProviderAsHeader = false
      style.horizontalPadding = 16.0
      return style
   }
}

#Preview("Default") {
   ChatSingleContentView(
      providerContent: LLMProviderContent(provider: .openAI, response: response),
      style: .defaultStyle,
      isScrollEnabled: true)
   .frame(height: 500)
}

#Preview("asPartOfMultipleContentVertical") {
   ChatSingleContentView(
      providerContent: LLMProviderContent(provider: .openAI, response: response),
      style: .asPartOfMultipleContentVertical,
      isScrollEnabled: true)
   .frame(height: 500)
}

#Preview("asPartOfMultipleContentHorizontal") {
   ChatSingleContentView(
      providerContent: LLMProviderContent(provider: .openAI, response: response),
      style: .asPartOfMultipleContentHorizontal,
      isScrollEnabled: true)
   .frame(height: 500)
}

#Preview("Analyzing") {
   ChatSingleContentView(
      providerContent: LLMProviderContent(provider: .openAI, response: response),
      style: .analyzing,
      isScrollEnabled: false)
   .frame(height: 1000)
}


let response = """
Here is an example of a SwiftUI Button:
```
import SwiftUI

struct MyButton: View {
    var body: some View {
        Button("Click me!") {
            // Action when the button is tapped
            print("Button tapped!")
        }
    }
}
```
Let's break this down:

* `struct MyButton: View` defines a new SwiftUI view called `MyButton`. The `: View` part tells Swift that this struct conforms to the `View` protocol, which means it can be used in a SwiftUI hierarchy.
* `var body: some View { ... }` defines the content of the `MyButton` view. In this case, we're using a `Button` control, which is a built-in SwiftUI control that responds to taps.
* The first argument to the `Button` initializer is the title of the button, in this case `"Click me!"`.
* The second argument to the `Button` initializer is a closure that defines what should happen when the button is tapped. In this case, we're simply printing a message to the console using `print`.

To use this button in your app, you would create an instance of the `MyButton` struct and add it to your view hierarchy:
```
struct MyView: View {
    var body: some View {
        MyButton()
            .frame(maxWidth:.infinity)
            .padding()
    }
}
```
This code defines a new SwiftUI view called `MyView`, which contains an instance of the `MyButton` struct. The `frame` and `padding` modifiers are used to customize the appearance of the button.
"""
