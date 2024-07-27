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
   
   init(service: PolyAIService) {
      self.service = service
   }
   
   var messages: [ChatMessageViewModel] = []
   var availableProviders: [LLMProvider] = []
      
   func udpateConfigurations(_ configurations: [LLMConfiguration]) {
      service = PolyAIServiceFactory.serviceWith(configurations)
   }
   
   func analyze(
      multipleContent: LLMMultiProvidersContent,
      with provider: LLMProvider) async throws
   {
      // Get last user's query.
      let lastUserQuery = lastMessageOf(type: .user)?.message.userPrompt ?? ""
      let systemMessage = LLMMessage(role: .system, content: Prompts.analyzingSystemPrompt)
      let userPrompt = Prompts.analyzeUsersPrompt(lastUserQuery, content: multipleContent.formattedContent)
      Prompts.printHelper(context: "User Prompt to analyze", content: userPrompt)
      let usersMessage = LLMMessage(role: .user, content: userPrompt)
      let messages = [systemMessage, usersMessage]
      let parameter = provider.parameter(messages, maxTokens: 1000)
      try await analyze(with: parameter)
   }
   
   func sendUserPrompt(
      _ prompt: String,
      selectedProviders: [LLMProvider])
   {
      let parameters = selectedProviders.map { $0.parameter([.init(role: .user, content: prompt)], maxTokens: 1000) }
      // Add users message to ui
      messages.append(ChatMessageViewModel(message: .user(prompt: prompt)))
      
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
               
               messages.append(ChatMessageViewModel(message: .assistant(content: newMultipleContent)))
               
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
   
   // MARK: Private
   
   private func handleParameter(
      _ parameter: LLMParameter, at index: Int)
   async throws
   {
      guard index < messages.count else { return }
      let currentMessage = messages[index]
      for try await chunk in self.streamString(parameter: parameter) {
         switch currentMessage.message {
         case .assistant(let multipleContent):
            if let content = multipleContent.content[parameter.provider] {
               content.response += chunk
               Prompts.printHelper(context: "Gen AI: \(parameter.provider)", content: content.response)
               messages[index] = currentMessage
            }
         case .analyze(let content):
            content.response += chunk
            messages[index] = currentMessage
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
   
   private func analyze(
      with parameter: LLMParameter)
      async throws
   {
      messages.append(ChatMessageViewModel(message: .analyze(response: .init(provider: parameter.provider, response: ""))))
      let currentIndex = messages.count - 1
      try await handleParameter(parameter, at: currentIndex)
   }
   
   private func lastMessageOf(
      type: ChatMessageViewModel.Message.MessageType)
      -> ChatMessageViewModel?
   {
      messages.last { message in
         message.message.type == type
      }
   }
   
   private var service: PolyAIService
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
