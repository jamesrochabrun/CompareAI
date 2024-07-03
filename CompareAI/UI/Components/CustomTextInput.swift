//
//  CustomTextInput.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/22/24.
//

import Foundation
import SwiftUI

struct CustomTextInput: View {
   
   // MARK: Internal
   
   enum InputState {
      case send(prompt: String, imageURL: URL?, selectedProviders: [LLMProvider])
      case hold
   }
   
   @Binding var prompt: String
   
   /// if `True` images can be added as input.
   let isImageInputEnabled: Bool
   
   /// Is a streaming chat response in progress
   let isStreamingResponse: Bool
   
   /// Send button may be disabled if there is an error during stream
   let isSendButtonDisabled: Bool
   
   let availableProviders: [LLMProvider]
   
   /// Callback invoked when the user taps the submit button or presses return
   var didSubmit: (InputState) -> Void
   
   /// Callback invoked when the user taps on the stop button
   var didTapStop: () -> Void
   
   var body: some View {
      VStack(spacing: 0) {
         VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 0) {
               chatInputTextEditor
                  .padding(.vertical, 8)
               actionButton
               providerSelectorButton
            }
         }
         .padding(.vertical, 8)
      }
      .padding(.horizontal)
   }
   
   // MARK: Private
   
   @State private var image = Image(systemName: "photo")
   @State private var imageURL: URL? = nil
   @Environment(\.colorScheme) private var colorScheme
   @State private var showModelsSelector = false
   @State private var selectedProviders: [LLMProvider] = []
   @FocusState private var isTextFieldFocused: Bool
   private let textAreaEdgeInsets = EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
   private let textAreaCornerRadius = 24.0
   
   private var chatInputTextEditor: some View {
      ZStack(alignment: .top) {
         TextEditor(text: $prompt)
            .scrollContentBackground(.hidden)
            .focused($isTextFieldFocused)
            .font(.title3)
            .frame(maxHeight: 200)
            .fixedSize(horizontal: false, vertical: true)
         // Resources: https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-and-respond-to-key-press-events
            .onKeyPress(keys: [.return]) { press in
               handleOnReturnPress(press)
            }
            .onAppear {
               isTextFieldFocused = true
            }
            .padding(textAreaEdgeInsets)
         if prompt.isEmpty {
            placeholder
               .padding(textAreaEdgeInsets)
         }
      }
      .clipShape(RoundedRectangle(cornerRadius: textAreaCornerRadius))
      .overlay(
         RoundedRectangle(cornerRadius: textAreaCornerRadius)
            .stroke(Colors.textAreaBorderColor(colorScheme), lineWidth: 1))
   }
   
   private var placeholder: some View {
      Text("Ask anything")
         .font(.title3)
         .foregroundColor(.gray)
         .frame(maxWidth: .infinity, alignment: .leading)
         .padding(.horizontal, 6)
         .onTapGesture {
            isTextFieldFocused = true
         }
   }
   
   private var actionButton: some View {
      Button {
         if isStreamingResponse {
            didTapStop()
         } else {
            submitRequest()
         }
      } label: {
         Image(systemName: isStreamingResponse ? "stop.circle" : "paperplane")
            .font(.title)
            .foregroundColor((isStreamingResponse || prompt.isEmpty) ? .primary : .secondary)
      }
      .disabled(isSendButtonDisabled)
      .buttonStyle(.plain)
      .padding(.horizontal, 8)
   }
   
   private var providerSelectorButton: some View {
      Button {
         showModelsSelector = true
      } label: {
         Image(systemName: showModelsSelector ? "xmark" : "plus")
            .font(.title)
      }
      .buttonStyle(.plain)
      .padding(.horizontal, 8)
      .popover(isPresented: $showModelsSelector) {
         LLMProviderSelectionView(
            availableProviders: availableProviders,
            selectedProviders: $selectedProviders)
      }
   }
   
   private func submitRequest() {
      guard !isStreamingResponse else {
         didSubmit(.hold)
         return
      }
      guard prompt.isEmpty, selectedProviders.isEmpty else {
         // TODO: Show an alert to say hey select a provider and try again.
         return
      }
      didSubmit(.send(prompt: prompt, imageURL: imageURL, selectedProviders: selectedProviders))
      prompt = ""
      resetImage()
   }
   
   private func resetImage() {
      imageURL = nil
      image = Image(systemName: "photo")
   }
}

// MARK: Actions

extension CustomTextInput {
   
   /// This method updates the action selector UI and also updates local state in response to a  `ChatInputSelectorAction`.
   ///
   /// - Parameter action: The new `ChatInputSelectorAction` that will trigger a local state update or chat input selector appearance.
   
   private func handleOnReturnPress(
      _ press: KeyPress)
   -> KeyPress.Result
   {
      // Shift + Return = Add new line
      if press.modifiers.contains(.shift) {
         prompt += "\n"
         return .ignored
      }
      
      submitRequest()
      return .handled
   }
}
