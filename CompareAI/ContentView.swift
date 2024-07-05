//
//  ContentView.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/20/24.
//

import SwiftUI
import PolyAI
import SwiftOpenAI

@MainActor
struct ContentView: View {
   
   @State private var llmConfigurations: [LLMConfiguration] = []
   @State private var availableProviders: [LLMProvider] = []
   @State private var chatScreenViewModel: ChatScreenViewModel = .init(service: PolyAIServiceFactory.serviceWith([]))
   
   var body: some View {
      NavigationSplitView {
         ConfigurationScreen(
            llmConfigurations: $llmConfigurations,
            availableProviders: $availableProviders)
      } detail: {
         ChatScreen(viewModel: chatScreenViewModel)
            .backgroundGaussianBlur(type: .behindWindow)
      }
      .onChange(of: colorScheme, initial: true) { _, newValue in
         codeSyntaxHighlighter.updateTheme(colorScheme: newValue)
      }
      .onChange(of: llmConfigurations) { _, newValue in
         chatScreenViewModel.udpateConfigurations(newValue)
      }
      .onChange(of: availableProviders) { _, newValue in
         chatScreenViewModel.availableProviders = newValue
      }
   }
   
   // MARK: Private
   
   @Environment(\.colorScheme) private var colorScheme
   @Environment(\.codeSyntaxHighlighter) private var codeSyntaxHighlighter
}

#Preview {
   ContentView()
}
