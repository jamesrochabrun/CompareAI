//
//  ChatViewModel.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/22/24.
//

import Foundation
import PolyAI

@MainActor
@Observable
final class ChatViewModel {
   
   // MARK: Lifecycle

   init(service: PolyAIService) {
     self.service = service
   }
   
   private let service: PolyAIService
   var messages: [ChatMessageViewModel] = []


}
