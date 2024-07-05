//
//  ChatMessageViewModel.swift
//  CompareAI
//
//  Created by James Rochabrun on 7/1/24.
//

import Foundation

@Observable
final class ChatMessageViewModel: Equatable, Identifiable {
   
   let id = UUID()
   
   static func == (lhs: ChatMessageViewModel, rhs: ChatMessageViewModel) -> Bool {
      lhs.message == rhs.message
   }
   
   init(message: Message) {
      self.message = message
   }
   
   var message: Message
   
   enum Message: Equatable {
      
      case user(prompt: String)
      case assistant(content: LLMMultiProvidersContent)
      case analyze(response: LLMProviderContent)
      
      enum MessageType {
         case user
         case assistant
         case analyze
      }
      
      var type: MessageType {
         switch self {
         case .user: return .user
         case .assistant: return .assistant
         case .analyze: return .analyze
         }
      }
      
      var userPrompt: String? {
         switch self {
         case .user(let prompt): return prompt
         default: return nil
         }
      }
   }
}
