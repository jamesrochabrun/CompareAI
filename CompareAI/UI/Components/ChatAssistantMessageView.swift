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
   let layout: ParentLayout
   
   enum ParentLayout {
      case horizontal
      case vertical
   }
   
   var body: some View {
      VStack(alignment: .leading, spacing: 24) {
         header
         Markdown(response)
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
            .markdownTheme(.custom(fontSize: 14, colorScheme: colorScheme))
            .markdownCodeSyntaxHighlighter(codeSyntaxHighlighter)
            .padding(.horizontal)
            .padding(.bottom)
      }
      .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
      .frame(maxHeight: maxHeight, alignment: .top)
      .background(.ultraThinMaterial)
      .cornerRadius(10)
      .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
      .overlay(
         RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
      )
   }
   
   private var header: some View {
      HStack {
         Text(providerName)
            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
            .fontWeight(.semibold)
            .clipped()
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .textSelection(.enabled)
         if layout == .vertical {
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
   
   private var maxHeight: CGFloat? {
      switch layout {
      case .horizontal: return nil
      case .vertical: return isExpanded ? nil : 200
      }
   }
   
   @Environment(\.colorScheme) private var colorScheme
   @Environment(\.codeSyntaxHighlighter) private var codeSyntaxHighlighter
   @State private var isExpanded: Bool = false
}
