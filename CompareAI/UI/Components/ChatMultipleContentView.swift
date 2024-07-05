//
//  ChatMultipleContentView.swift
//  CompareAI
//
//  Created by James Rochabrun on 7/5/24.
//

import Foundation
import SwiftUI

enum ChatContentLayout {
   case horizontal
   case vertical
}

struct ChatMultipleContentView: View {
   
   let multipleContent: LLMMultiProvidersContent
   let layout: ChatContentLayout
   let internalLayout: AnyLayout
   let isChildrenScrollingEnabled: Bool
   let analyze: (LLMMultiProvidersContent) -> Void
   
   init(
      multipleContent: LLMMultiProvidersContent,
      layout: ChatContentLayout,
      isChildrenScrollingEnabled: Bool,
      analyze: @escaping (LLMMultiProvidersContent) -> Void)
   {
      self.multipleContent = multipleContent
      self.layout = layout
      internalLayout = layout == .horizontal ? AnyLayout(HStackLayout(alignment: .top)) : AnyLayout(VStackLayout(alignment: .center))
      self.isChildrenScrollingEnabled = isChildrenScrollingEnabled
      self.analyze = analyze
   }
   
   var body: some View {
      VStack(alignment: .leading) {
         Text("Providers:")
            .font(.headline)
         internalLayout{
            ForEach(multipleContent.content) { content in
               ChatSingleContentView(
                  providerContent: content,
                  style: layout == .vertical ? .asPartOfMultipleContentVertical : .asPartOfMultipleContentHorizontal,
                  isScrollEnabled: isChildrenScrollingEnabled)
            }
         }
         .padding(12)
         .card(border: Colors.multipleContentViewBorderColor(colorScheme), cornerRadius: 6)
         footer
            .padding(.top, 4)
      }
      .padding()
   }
   
   var footer: some View {
      HStack {
         Button {
            analyze(multipleContent)
         } label: {
            HStack(spacing: 0) {
               Text("Compare Using Sonnet 3.5")
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .foregroundColor(.white) // Set the text and icon color
            .background(.tertiary)
            .clipShape(RoundedRectangle(cornerRadius: 16)) // Clip the shape to a capsule
         }
         .buttonStyle(.plain)
      }
   }
   
   @Environment(\.colorScheme) private var colorScheme
}

#Preview("ChldrenScrolledEnabled") {
   ChatMultipleContentView(
      multipleContent: .init(content: [
         .init(provider: .anthropic, response: response),
         .init(provider: .openAI, response: response),
         .init(provider: .gemini, response: response),
         .init(provider: .llama3, response: response),
      ]),
      layout: .horizontal,
      isChildrenScrollingEnabled: true, analyze: { _ in })
   .frame(width: 850, height: 400)
   .padding()
}

#Preview("ChldrenScrolleDisabled") {
   ChatMultipleContentView(
      multipleContent: .init(content: [
         .init(provider: .anthropic, response: response),
         .init(provider: .openAI, response: response),
         .init(provider: .gemini, response: response),
         .init(provider: .llama3, response: response),
      ]),
      layout: .horizontal,
      isChildrenScrollingEnabled: false, analyze: { _ in })
   .frame(width: 1000, height: 1000)
   .padding()
}
