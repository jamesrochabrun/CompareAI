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
}

final class MultipleContent: Identifiable {
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

@Observable
@MainActor
final class LLMProvider {
   
   let service: PolyAIService

   var multipleContent: [MultipleContent] = []
   
   init(service: PolyAIService) {
      self.service = service
   }
   
   func generate(parameters: [LLMParameter]) {
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
               multipleContent.append(newMultipleContent) // Append once here

               // Index of the newly added MultipleContent
               let currentIndex = multipleContent.count - 1
               
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
      guard index < multipleContent.count else { return }
      let currentContent = multipleContent[index]
      
      for try await chunk in self.streamString(parameter: parameter) {
         if let content = currentContent.content[Provider(rawValue: parameter.llmService)!] {
            content.response += chunk
            multipleContent[index] = currentContent
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
