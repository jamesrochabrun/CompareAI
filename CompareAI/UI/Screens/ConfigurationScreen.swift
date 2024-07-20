//
//  ConfigurationScreen.swift
//  CompareAI
//
//  Created by James Rochabrun on 7/2/24.
//

import Foundation
import PolyAI
import SwiftOpenAI
import SwiftUI

// MARK: ConfigurationScreen

struct ConfigurationScreen: View {
   
   @Binding var llmConfigurations: [LLMConfiguration]
   @Binding var availableProviders: [LLMProvider]

   var body: some View {
      VStack {
         ForEach(LLMProvider.allCases) { provider in
            LLMConfigurationView(
               provider: provider,
               addConfig: { llmConfiguration, provider in
                  llmConfigurations.append(llmConfiguration)
                  availableProviders.append(provider)
               }, removeConfig: { llmConfiguration, provider in
                  if let index = llmConfigurations.firstIndex(of: llmConfiguration) {
                     llmConfigurations.remove(at: index)
                  }
                  if let providerIndex = availableProviders.firstIndex(of: provider) {
                     availableProviders.remove(at: providerIndex)
                  }
               })
         }
         Spacer()
      }
      .padding()
   }
}

// MARK: LLMConfigurationView

struct LLMConfigurationView: View {
   
   let provider: LLMProvider
   let addConfig: (LLMConfiguration, LLMProvider) -> Void
   let removeConfig: (LLMConfiguration, LLMProvider) -> Void

   @State private var apiKey: String = ""
   @State private var configurationAdded = false
   
   var body: some View {
      VStack(alignment: .leading) {
         HStack {
            TextField(provider.apiKeyInputText, text: $apiKey)
            Button {
               if configurationAdded {
                  removeConfig(provider.configuration(apiKey), provider)
                  configurationAdded = false
               } else {
                  addConfig(provider.configuration(apiKey), provider)
                  configurationAdded = true
               }
       
            } label: {
               Image(systemName: configurationAdded ? "minus" : "plus")
            }
            .buttonStyle(.plain)
            .disabled(apiKey.isEmpty)
         }
         HStack {
            Text(provider.displayName)
            Text("Active")
               .bold()
         }
         .opacity(configurationAdded ? 1 : 0)
      }
   }
}

// MARK: LLMConfiguration+Equatable

extension LLMConfiguration: Equatable {
   public static func == (lhs: LLMConfiguration, rhs: LLMConfiguration) -> Bool {
      switch (lhs, rhs) {
      case (.openAI(let lhsOpenAI), .openAI(let rhsOpenAI)):
         return lhsOpenAI == rhsOpenAI
      case (.anthropic(let lhsApiKey, let lhsConfig), .anthropic(let rhsApiKey, let rhsConfig)):
         return lhsApiKey == rhsApiKey && lhsConfig == rhsConfig
      case (.gemini(let lhsApiKey), .gemini(let rhsApiKey)):
         return lhsApiKey == rhsApiKey
      case (.ollama(let lhsUrl), .ollama(let rhsUrl)):
         return lhsUrl == rhsUrl
      default:
         return false
      }
   }
}

extension LLMConfiguration.OpenAI: Equatable {
   public static func == (lhs: LLMConfiguration.OpenAI, rhs: LLMConfiguration.OpenAI) -> Bool {
      switch (lhs, rhs) {
      case (.api(let lhsKey, let lhsOrgID, let lhsConfig, _),
            .api(let rhsKey, let rhsOrgID, let rhsConfig, _)):
         return lhsKey == rhsKey && lhsOrgID == rhsOrgID && lhsConfig == rhsConfig
      case (.azure(let lhsConfig, let lhsUrlConfig, _),
            .azure(let rhsConfig, let rhsUrlConfig, _)):
         return lhsConfig == rhsConfig && lhsUrlConfig == rhsUrlConfig
      case (.aiProxy(let lhsPartialKey, let lhsClientID), .aiProxy(let rhsPartialKey, let rhsClientID)):
         return lhsPartialKey == rhsPartialKey && lhsClientID == rhsClientID
      default:
         return false
      }
   }
}

extension AzureOpenAIConfiguration: Equatable {
   public static func == (lhs: SwiftOpenAI.AzureOpenAIConfiguration, rhs: SwiftOpenAI.AzureOpenAIConfiguration) -> Bool {
      false // TODO: When Azure is supported.
   }
}
