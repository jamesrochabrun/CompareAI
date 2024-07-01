//
//  ContentView.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/20/24.
//

import SwiftUI
import PolyAI
import SwiftOpenAI

struct ContentView: View {
   
   let service = PolyAIServiceFactory.serviceWith([
      .openAI(.api(key: "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")),
      .anthropic(apiKey: "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"),
      .gemini(apiKey: "AIzaSyCbaQcnih3bIDNQ-RuSO3mC79t1TDQFYXk"),
      .ollama(url: "http://localhost:11434")
   ])
      
   var body: some View {
      ChatScreen(service: service)
         .backgroundGaussianBlur(type: .behindWindow)
         .onChange(of: colorScheme, initial: true) { _, newValue in
            codeSyntaxHighlighter.updateTheme(colorScheme: newValue)
         }
   }
   
   // MARK: Private
   
   @Environment(\.colorScheme) private var colorScheme
   @Environment(\.codeSyntaxHighlighter) private var codeSyntaxHighlighter
   
}

#Preview {
   ContentView()
}
