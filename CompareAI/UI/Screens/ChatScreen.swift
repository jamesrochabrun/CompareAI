//
//  ChatScreen.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/22/24.
//

import Foundation
import PolyAI
import SwiftUI

struct BubbleText: View {
   
   let text: String
   var body: some View {
      Text(text)
         .padding(.horizontal)
         .padding(.vertical, 8)
         .background(Color.black.opacity(0.2)) // Use a material background
         .clipShape(Capsule()) // Clip the background to a capsule shape
         .overlay(
            Capsule()
               .foregroundColor(.clear)
            // .stroke(Color.gray.opacity(0.5), lineWidth: 1) // Add a border to the capsule
         )
   }
}

@MainActor
struct ChatScreen: View {
   
   init(service: PolyAIService) {
      lLMProvider = .init(service: service)
   }
   
   var body: some View {
      VStack {
         ScrollView {
            ForEach(lLMProvider.messages) { message in
               switch message {
               case .user(let prompt):
                  HStack {
                     BubbleText(text: prompt)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                  }
                  .padding()
               case .assistant(let multipleContent):
                  HStack(alignment: .top) {
                     ForEach(multipleContent.content) { response in
                        CodeBlockView(header: response.provider.displayName, text: response.response)
                           .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                           .padding() // Optional: Add some padding for a nicer layout
                           .background(Colors.chatBackgroundColor(colorScheme)) // Background color for the card
                           .cornerRadius(10) // Rounded corners
                           .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2) // Shadow for the card
                           .overlay(
                               RoundedRectangle(cornerRadius: 10)
                                   .stroke(response.provider.borderColor, lineWidth: 1) // Border with the specified color
                           )
                     }
                  }
                  .padding()
               }
            }
         }
         textArea
      }
      .background(.clear)
     // .background(Colors.chatBackgroundColor(colorScheme))
   }
   
   let lLMProvider: LLMProvider
   
   var textArea: some View {
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
   }
   
   @State private var prompt: String = ""
   @Environment(\.colorScheme) private var colorScheme

}


