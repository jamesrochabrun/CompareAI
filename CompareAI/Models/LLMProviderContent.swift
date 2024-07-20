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

@Observable
final class LLMProviderContent: Equatable {
   
   static func == (lhs: LLMProviderContent, rhs: LLMProviderContent) -> Bool {
      lhs.id == rhs.id
   }
   let provider: LLMProvider
   var response: String = ""
   
   init(
      provider: LLMProvider,
      response: String = "")
   {
      self.provider = provider
      self.response = response
   }
}

extension LLMProviderContent: Identifiable {
   
   var id: LLMProvider { provider }
}

// MARK: Provider

enum LLMProvider: String {
   case openAI = "OpenAI"
   case anthropic = "Anthropic"
   case gemini = "Gemini"
   case llama3 = "llama3"
}

extension LLMProvider: Identifiable, CaseIterable {
   
   var id: Self {
      self
   }
   
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
   
   var apiKeyInputText: String {
      switch self {
      case .llama3:
         "Enter Ollama local Host URL"
      default:
         "Enter \(rawValue) API Key"
      }
   }
   
   func parameter(
      _ messages: [LLMMessage],
      maxTokens: Int)
   -> LLMParameter
   {
      switch self {
      case .openAI: return .openAI(model: .gpt4o, messages: messages, maxTokens: maxTokens)
      case .anthropic: return .anthropic(model: .claude35Sonnet, messages: messages, maxTokens: maxTokens)
      case .gemini: return .gemini(model: "gemini-1.5-pro-001", messages: messages, maxTokens: maxTokens)
      case .llama3: return .ollama(model: "llama3", messages: messages, maxTokens: maxTokens)
      }
   }
   
   func configuration(_ value: String) -> LLMConfiguration {
      switch self {
      case .openAI: return .openAI(.api(key: value))
      case .anthropic: return .anthropic(apiKey: value)
      case .gemini: return .gemini(apiKey: value)
      case .llama3: return .ollama(url: value)
      }
   }
}

// MARK: LLMParameter

extension LLMParameter {
   
   var provider: LLMProvider {
      switch self {
      case .openAI: return .openAI
      case .anthropic: return .anthropic
      case .gemini: return .gemini
      case .ollama(_, _, _): return .llama3
      }
   }
}
