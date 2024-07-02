//
//  ChatScreen.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/22/24.
//

import Foundation
import PolyAI
import SwiftUI

@MainActor
struct ChatScreen: View {
   
   // MARK: Initializer

   init(service: PolyAIService) {
      lLMProvider = .init(service: service)
   }
   
   var body: some View {
      VStack {
         if lLMProvider.messages.isEmpty {
            emptyView
         } else {
            chat
            textArea
         }
      }
      .animation(.linear, value: lLMProvider.messages.isEmpty)
   }
   
   // MARK: Private
   
   private let lLMProvider: LLMProvider
   
   private var emptyView: some View {
      VStack {
         HStack {
            Image(systemName: "lessthan")
            Text("CompareAI")
         }
         .font(.largeTitle)
         .fontWeight(.semibold)
         .fontDesign(.monospaced)
         textArea
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
   }
   
   private var chat: some View {
      ScrollView {
         ForEach(lLMProvider.messages) { message in
            switch message {
            case .user(let prompt):
               ChatUserMessageView(text: prompt)
                  .frame(maxWidth: .infinity, alignment: .trailing)
                  .padding()
            case .assistant(let multipleContent):
               HStack(alignment: .top) {
                  ForEach(multipleContent.content) { content in
                     ChatAssistantMessageView(
                        providerName: content.provider.displayName,
                        response: content.response)
                  }
               }
               .padding()
            }
         }
      }
   }
   
   private var textArea: some View {
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
               lLMProvider.generate(
                  prompt: prompt,
                  parameters: [
                     .openAI(model: .gpt4o, messages: [message], maxTokens: 1000),
                     .anthropic(model: .claude35Sonnet, messages: [message], maxTokens: 1000),
                     .gemini(model: "gemini-1.5-pro-001", messages: [message], maxTokens: 1000),
                     .ollama(model: "llama3", messages: [message], maxTokens: 1000)
                  ])
            }
         },
         didTapStop: {})
      .frame(maxWidth: 750)
   }
   
   @State private var prompt: String = ""
   @Environment(\.colorScheme) private var colorScheme
}


