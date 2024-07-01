//
//  LLMProvider.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/21/24.
//

import Foundation
import PolyAI
import SwiftUI

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

final class MultipleContent: Identifiable, Equatable {
   static func == (lhs: MultipleContent, rhs: MultipleContent) -> Bool {
      lhs.id == rhs.id
   }
   
   let id = UUID()
   var content: [Content]
   
   init(content: [Content]) {
      self.content = content
   }
}

final class Content: Identifiable {
   var id: Provider {
      provider
   }
   let provider: Provider
   var response: String = ""
   
   init(provider: Provider, response: String = "") {
      self.provider = provider
      self.response = response
   }
}

enum Message: Equatable, Identifiable {
   case user(prompt: String)
   case assistant(content: MultipleContent)
   
   var id: String {
      switch self {
      case .user(let prompt): return "\(UUID().uuidString) \(prompt)"
      case .assistant(let content): return content.id.uuidString
      }
   }
}

@Observable
@MainActor
final class LLMProvider {
   
   let service: PolyAIService
   
   var messages: [Message] = []
   
   init(service: PolyAIService) {
      self.service = service
   }
   
   func generate(prompt: String, parameters: [LLMParameter]) {
      
      // Add message to ui
      messages.append(.user(prompt: prompt))
      
      Task {
         do {
            try await withThrowingTaskGroup(of: Void.self) { group in
               // Initialize a new MultipleContent for this set of parameters
               let newMultipleContent = MultipleContent(content: [
                   Content(provider: .openAI),
                   Content(provider: .anthropic),
                   Content(provider: .gemini),
               Content(provider: .llama3)
               ])
               
               messages.append(.assistant(content: newMultipleContent))

               // Index of the newly added MultipleContent
               let currentIndex = messages.count - 1
               
               for parameter in parameters {
                  group.addTask {
                     try await self.handleParameter(parameter, at: currentIndex)
                  }
               }
               try await group.waitForAll()
            }
         } catch {
            print("An error occurred: \(error)")
         }
      }
   }
   
   private func handleParameter(
      _ parameter: LLMParameter, at index: Int)
      async throws
   {
      guard index < messages.count else { return }
      let currentContent = messages[index]
      
      for try await chunk in self.streamString(parameter: parameter) {
         switch currentContent {
         case .assistant(let content):
            if let content = content.content[Provider(rawValue: parameter.llmService)!] {
               content.response += chunk
               messages[index] = currentContent
            }
         default:
            break
         }
         
         

      }
   }
   
   private func streamString(
      parameter: LLMParameter)
   -> AsyncThrowingStream<String, Error>
   {
      AsyncThrowingStream { continuation in
         Task {
            do {
               let stream = try await service.streamMessage(parameter)
               for try await result in stream {
                  if let content = result.content {
                     continuation.yield(content)
                  }
               }
               continuation.finish()
            } catch {
               continuation.finish(throwing: error)
            }
         }
      }
   }
}


extension [Content] {
   
   subscript(provider: Provider) -> Content? {
       get {
           return self.first(where: { $0.provider == provider })
       }
       set {
           if let index = self.firstIndex(where: { $0.provider == provider }) {
               if let newValue = newValue {
                   self[index] = newValue
               } else {
                   self.remove(at: index)
               }
           } else if let newValue = newValue {
               self.append(newValue)
           }
       }
   }
}

extension LLMParameter {
   
   var llmService: String {
      switch self {
      case .openAI: return "OpenAI"
      case .anthropic: return "Anthropic"
      case .gemini: return "Gemini"
      case .ollama(let model, _, _): return model
      }
   }
}
