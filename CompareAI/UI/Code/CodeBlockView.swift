//
//  CodeBlockView.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/21/24.
//

import Foundation
import MarkdownUI
import SwiftUI

struct CodeBlockView: View {
   
   let header: String
   let text: String
   
   var body: some View {
      VStack(alignment: .leading, spacing: 24) {
         Text(header)
            .font(.title3)
         Markdown(text)
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
            .markdownTheme(.custom(fontSize: 14, colorScheme: colorScheme))
            .markdownCodeSyntaxHighlighter(codeSyntaxHighlighter)
      }
   }
   
   @Environment(\.colorScheme) private var colorScheme
   @Environment(\.codeSyntaxHighlighter) private var codeSyntaxHighlighter
}
