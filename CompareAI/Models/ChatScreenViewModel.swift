//
//  ChatScreenViewModel.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/21/24.
//

import Foundation
import PolyAI
import SwiftUI

@Observable
@MainActor
final class ChatScreenViewModel {
   
   let service: PolyAIService
   
   var messages: [ChatMessageViewModel] = []
   
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
               
               var content: [LLMProviderContent] = []
               for parameter in parameters {
                  switch parameter {
                  case .openAI:
                     content.append(.init(provider: .openAI))
                  case .anthropic:
                     content.append(.init(provider: .anthropic))
                  case .gemini:
                     content.append(.init(provider: .gemini))
                  case .ollama:
                     content.append(.init(provider: .llama3))
                  }
               }
                              
               let newMultipleContent = LLMMultiProvidersContent(content: content)
               
               messages.append(.assistant(content: newMultipleContent))

               // Index of the newly added assistant MultipleContent
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
      let currentMessage = messages[index]
      
      for try await chunk in self.streamString(parameter: parameter) {
         switch currentMessage {
         case .assistant(let multipleContent):
            if let content = multipleContent.content[parameter.provider] {
               content.response += chunk
               messages[index] = currentMessage
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


extension [LLMProviderContent] {
   
   subscript(provider: LLMProvider) -> LLMProviderContent? {
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
