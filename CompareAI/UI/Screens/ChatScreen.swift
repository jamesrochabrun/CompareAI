//
//  ChatScreen.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/22/24.
//

import Foundation
import SwiftUI

@MainActor
struct ChatScreen: View {
   
   // MARK: Initializer

   init(viewModel: ChatScreenViewModel) {
      self.viewModel = viewModel
   }
   
   var body: some View {
      VStack {
         if viewModel.messages.isEmpty {
            emptyView
         } else {
            chat
            textArea
         }
      }
      .animation(.linear, value: viewModel.messages.isEmpty)
   }
   
   // MARK: Private
   
   private let viewModel: ChatScreenViewModel
   
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
   @Environment(\.horizontalSizeClass) private var sizeClass

   private var chat: some View {
      GeometryReader { proxy in
         ScrollView {
            ForEach(viewModel.messages) { message in
               switch message {
               case .user(let prompt):
                  ChatUserMessageView(text: prompt)
                     .frame(maxWidth: .infinity, alignment: .trailing)
                     .padding()
               case .assistant(let multipleContent):
                  if proxy.size.width > 1000 {
                     HStack(alignment: .top) {
                        ForEach(multipleContent.content) { content in
                           ChatAssistantMessageView(
                              providerName: content.provider.displayName,
                              response: content.response,
                              layout: .horizontal)
                        }
                     }
                     .padding()
                  } else {
                     VStack(alignment: .center) {
                        ForEach(multipleContent.content) { content in
                           ChatAssistantMessageView(
                              providerName: content.provider.displayName,
                              response: content.response,
                              layout: .vertical)
                        }
                     }
                     .padding()
                  }
               }
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
         availableProviders: viewModel.availableProviders,
         didSubmit: { state in
            switch state {
            case .hold:
               break
            case .send(let prompt, _, let selectedProviders):
               viewModel.generate(
                  prompt: prompt,
                  parameters: selectedProviders.map { $0.parameter(prompt, maxTokens: 1000) })
            }
         },
         didTapStop: {})
      .frame(maxWidth: 750)
   }
   
   @State private var prompt: String = ""
   @Environment(\.colorScheme) private var colorScheme
}
