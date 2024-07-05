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
            Image(systemName: "greaterthan")
            Text("CompareAI")
         }
         .font(.largeTitle)
         .fontWeight(.semibold)
         .fontDesign(.monospaced)
         textArea
      }
      .padding(.horizontal)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
   }
   @Environment(\.horizontalSizeClass) private var sizeClass
   
   private var chat: some View {
      GeometryReader { proxy in
         ScrollView {
            ForEach(viewModel.messages) { message in
               switch message.message {
               case .analyze(let content):
                  ChatSingleContentView(
                     providerContent: content,
                     style: .analyzing,
                     isScrollEnabled: false)
               case .user(let prompt):
                  ChatUserMessageView(text: prompt)
               case .assistant(let multipleContent):
                  if let firstContent = multipleContent.content.first, multipleContent.content.count == 1 {
                     ChatSingleContentView(
                        providerContent: firstContent,
                        style: .defaultStyle,
                        isScrollEnabled: false)
                  } else {
                     // horizontal: proxy.size.width > 1000
                     ChatMultipleContentView(
                        multipleContent: multipleContent,
                        layout: proxy.size.width > 1000 ? .horizontal : .vertical,
                        isChildrenScrollingEnabled: true,
                        analyze: { multipleContent in
                           Task {
                              try await viewModel.analyze(multipleContent: multipleContent, with: .anthropic)
                           }
                        })
                     // We only want to apply a max width for horizontal layout.
                     .frame(maxHeight: proxy.size.width > 1000 ? 500 : nil)
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
               viewModel.sendUserPrompt(prompt, selectedProviders: selectedProviders)
            }
         },
         didTapStop: {})
      .frame(maxWidth: 750)
   }
   
   @State private var prompt: String = ""
   @Environment(\.colorScheme) private var colorScheme
}

#Preview("Empty") {
   ChatScreen(viewModel: .init(service: PolyAIServiceFactory.serviceWith([])))
}

#Preview("Mock Single Content") {
   let viewModel = ChatScreenViewModel(service: PolyAIServiceFactory.serviceWith([]))
   viewModel.messages = [
      .init(message: .user(prompt: "What is this?")),
      .init(message: .assistant(content: .init(content: [
         LLMProviderContent(provider: .openAI, response: response)
      ]))),
      .init(message: .analyze(response: LLMProviderContent(provider: .openAI, response: response)))
   ]
   return ChatScreen(viewModel: viewModel).frame(height: 800)
}

#Preview("Mock Multiple Content wide") {
   let viewModel = ChatScreenViewModel(service: PolyAIServiceFactory.serviceWith([]))
   viewModel.messages = [
      .init(message: .user(prompt: "What is this?")),
      .init(message: .assistant(content: .init(content: [
         LLMProviderContent(provider: .openAI, response: response),
         LLMProviderContent(provider: .anthropic, response: response),
         LLMProviderContent(provider: .llama3, response: response),
         LLMProviderContent(provider: .gemini, response: response)
      ]))),
      .init(message: .analyze(response: LLMProviderContent(provider: .openAI, response: response)))
   ]
   return ChatScreen(viewModel: viewModel).frame(width: 1200, height: 800)
}

#Preview("Mock Multiple Content vertical") {
   let viewModel = ChatScreenViewModel(service: PolyAIServiceFactory.serviceWith([]))
   viewModel.messages = [
      .init(message: .user(prompt: "What is this?")),
      .init(message: .assistant(content: .init(content: [
         LLMProviderContent(provider: .openAI, response: response),
         LLMProviderContent(provider: .anthropic, response: response),
         LLMProviderContent(provider: .llama3, response: response),
         LLMProviderContent(provider: .gemini, response: response)
      ]))),
      .init(message: .analyze(response: LLMProviderContent(provider: .openAI, response: response)))
   ]
   return ChatScreen(viewModel: viewModel).frame(width: 800, height: 800)
}
