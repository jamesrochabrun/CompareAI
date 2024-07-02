//
//  ChatMessageViewModel.swift
//  CompareAI
//
//  Created by James Rochabrun on 7/1/24.
//

import Foundation

enum ChatMessageViewModel: Equatable {
   
   case user(prompt: String)
   case assistant(content: LLMMultiProvidersContent)
}

extension ChatMessageViewModel: Identifiable {
   
   var id: String {
      switch self {
      case .user(let prompt): return "\(UUID().uuidString) \(prompt)"
      case .assistant(let content): return content.id.uuidString
      }
   }
}
