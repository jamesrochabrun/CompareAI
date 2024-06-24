//
//  ChatService.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/22/24.
//

import Foundation
import PolyAI

/// Asynchronously sends prompts to LLM and streams back the response.
protocol ChatService: Actor {

  var service: PolyAIService { get }

  /// Add a user's request in the chat history and streams the response back. allowing for safe concurrent modifications
  /// to the conversation's state.
  ///
  ///  - parameter parameters: The ChatCompletionParameters for the chat completion request.
  ///
  /// - Returns:
  ///   An `AsyncThrowingStream<String, Error>` that streams text messages.
  ///
  /// - Throws: An `Error` if the request fails.
  func addUserRequestToConversation(
    parameters: [LLMParameter])
    async throws -> AsyncThrowingStream<String, Error>

  /// Deletes the message history associated with a conversation.
  ///
  /// By deleting the message
  /// history, it effectively resets the state, clearing any parameters that might be passed
  /// to subsequent interactions or chat completion requests.
  ///
  /// Usage:
  /// - Call this method when you need to clear a conversation's history, typically in response
  ///   to user actions or when preparing the conversation environment for a new chat session.
  func deleteConversation() async
}
