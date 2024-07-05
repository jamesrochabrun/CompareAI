//
//  LLMMultiProvidersContent.swift
//  CompareAI
//
//  Created by James Rochabrun on 7/1/24.
//

import Foundation

// MARK: LLMMultiProvidersContent

struct LLMMultiProvidersContent: Identifiable {
   
   let id = UUID()

   let content: [LLMProviderContent]
   
   init(content: [LLMProviderContent]) {
      self.content = content
   }
   
   var formattedContent: String {
      var text = ""
      for providerContent in content {
         text += """
         
         Provider: \(providerContent.provider.displayName)
         Response: \(providerContent.response)
         
         """
      }
      return text
   }
}

// MARK: LLMMultiProvidersContent+Equatable

extension LLMMultiProvidersContent: Equatable {
   
   static func == (lhs: LLMMultiProvidersContent, rhs: LLMMultiProvidersContent) -> Bool {
      lhs.id == rhs.id
   }
}
