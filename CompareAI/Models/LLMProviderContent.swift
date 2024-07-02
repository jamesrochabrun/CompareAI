//
//  LLMProviderContent.swift
//  CompareAI
//
//  Created by James Rochabrun on 7/1/24.
//

import Foundation
import PolyAI
import SwiftUI

// MARK: LLMProviderContent

final class LLMProviderContent {
   
   let provider: Provider
   var response: String = ""
   
   init(
      provider: Provider,
      response: String = "")
   {
      self.provider = provider
      self.response = response
   }
}

extension LLMProviderContent: Identifiable {
   
   var id: Provider { provider }
}

// MARK: Provider

enum Provider: String {
   case openAI = "OpenAI"
   case anthropic = "Anthropic"
   case gemini = "Gemini"
   case llama3 = "llama3"
}

extension Provider {
   
   var borderColor: Color {
      switch self {
      case .openAI: .green
      case .anthropic: .brown
      case .gemini: .purple
      case .llama3: .blue
      }
   }
   
   var model: String {
      switch self {
      case .openAI: "GPT4o"
      case .anthropic: "Claude 3.5 Sonnet"
      case .gemini: "Gemini 1.5 Pro"
      case .llama3: "7B"
      }
   }
   
   var displayName: String {
      "\(self.rawValue) (\(model))"
   }
}

// MARK: LLMParameter

extension LLMParameter {

   var provider: Provider {
      switch self {
      case .openAI: return .openAI
      case .anthropic: return .anthropic
      case .gemini: return .gemini
      case .ollama(_, _, _): return .llama3
      }
   }
}
