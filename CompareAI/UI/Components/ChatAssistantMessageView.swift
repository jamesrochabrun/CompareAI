//
//  ChatAssistantMessageView.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/21/24.
//

import Foundation
import MarkdownUI
import SwiftUI

/// Represents the view for a single provider. e.g: Anthropic.
struct ChatAssistantMessageView: View {
   
   let providerName: String
   let response: String
   
   var body: some View {
      VStack(alignment: .leading, spacing: 24) {
         Text(providerName)
            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
            .font(.title3)
            .fontWeight(.semibold)
            .clipped()
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(.ultraThickMaterial)
            .textSelection(.enabled)
         Markdown(response)
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
            .markdownTheme(.custom(fontSize: 14, colorScheme: colorScheme))
            .markdownCodeSyntaxHighlighter(codeSyntaxHighlighter)
            .padding(.horizontal)
            .padding(.bottom)
      }
      .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
      .background(.ultraThinMaterial)
      .cornerRadius(10)
      .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
      .overlay(
         RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
      )
   }
   
   @Environment(\.colorScheme) private var colorScheme
   @Environment(\.codeSyntaxHighlighter) private var codeSyntaxHighlighter
}
