//
//  ChatScreen.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/22/24.
//

import Foundation
import PolyAI
import SwiftUI

struct ChatScreen: View {
   
   init(service: PolyAIService) {
      lLMProvider = .init(service: service)
   }
   
   var body: some View {
      VStack {
         List {
            ForEach(lLMProvider.multipleContent) { content in
               HStack(alignment: .top) {
                  ForEach(content.content) { response in
                     CodeBlockView(header: response.provider.rawValue, text: response.response)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .border(.red)
                  }
               }
            }
         }
         textArea
      }
   }
   
   let lLMProvider: LLMProvider
   
   var textArea: some View {
      HStack {
         Button {
            // chatViewModel
         } label: {
            Image(systemName: "clear")
         }
         .buttonStyle(.plain)
         CustomTextInput(
            prompt: $prompt,
            isImageInputEnabled: false,
            isStreamingResponse: false,
            isSendButtonDisabled: false,
            didSubmit: { state in
               switch state {
               case .hold:
                  break
               case .send(let prompt, _):
                  let message = LLMMessage(role: .user, content: prompt)
                  lLMProvider.generate(parameters: [
                     .openAI(model: .gpt4o, messages: [message], maxTokens: 1000),
                     .anthropic(model: .claude35Sonnet, messages: [message], maxTokens: 1000),
                     .gemini(model: "gemini-1.5-pro-001", messages: [message], maxTokens: 1000)
                  ])
               }
            },
            didTapStop: {})
      }
   }
   
   @State private var prompt: String = ""

}


