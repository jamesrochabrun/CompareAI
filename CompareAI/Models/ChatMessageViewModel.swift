//
//  ChatMessageViewModel.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/22/24.
//

import Foundation

struct ChatMessageViewModel: Identifiable, Equatable {
   
   // MARK: Internal
   
   enum Source {
      case user
      case assistant
   }
   
   /// Unique identifier
   let id = UUID()
   
   /// The body of the chat message
   var text: String
   
   /// The message source
   let source: Source
   
   /// Optional URL of the image input. This URL is used to reference the image provided by the user in a multimodal large language model chat experience.
   var imageURL: URL?
   
}
