//
//  DefaultChatService.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/22/24.
//

import Foundation
import PolyAI

// MARK: - ChatServiceError

//enum ChatServiceError: LocalizedError {
//  case busy
//  case error(Error)
//  case userMessageNotFound
//
//  var errorDescription: String? {
//    switch self {
//    case .busy:
//      "The chat service is currently busy, possibly due to an ongoing stream."
//    case .error(let error):
//      error.localizedDescription
//    case .userMessageNotFound:
//      "A user message is required to send a request. Please enter your message and try again."
//    }
//  }
//
//  public var recoverySuggestion: String? {
//    "If this persists, please consider clearing the chat and start again or check your internet connection. We apologize for the inconvenience!"
//  }
//}
//
//// MARK: - DefaultChatService
//
//final actor DefaultChatService: ChatService {
//
//  // MARK: Lifecycle
//
//   init(service: PolyAIService) {
//    self.service = service
//  }
//
//  // MARK: Internal
//
//  let service: PolyAIService
//
//  /// Add a user's request in the chat history and streams the response back.
//  func addUserRequestToConversation(
//    parameters: [LLMParameter])
//    async throws -> AsyncThrowingStream<String, Error>
//  {
//    // `streamingResponseAccumulator` will get updated during streaming. Check if it is nil before proceed with the next stream.
//    guard streamingResponseAccumulator == nil else {
//      let error = ChatServiceError.busy
//      throw error
//    }
//    streamingResponseAccumulator = ""
//
//
//    return try await startStreamedChat(resource: resource, parameters: finalParameters, assistantId: currentMessageIdentifier)
//  }
//
//  func deleteConversation() async {
//    messagesHistory = []
//    streamingResponseAccumulator = nil
//  }
//
//  // MARK: Private
//
//  private var messagesHistory: [LLMParameter] = []
//  private var streamingResponseAccumulator: String?
//
//  /// Starts a new stream.
//  ///
//  /// - Parameter resource: The resource where the request will be pointed to.
//  /// - Parameter parameters: The ChatCompletionParameters parameters for the new streamed request.
//  /// - Parameter assistantId: The identifier used to track which assistant is sending the message,
//  ///   allowing for the correct association of responses with the corresponding assistant.
//  ///
//  /// - Returns: An `AsyncThrowingStream` of `String`, representing the streamed responses, or throws an `Error` if the stream fails.
//  private func startStreamedChat(
//    parameters: [LLMMessage])
//    async throws -> AsyncThrowingStream<String, Error>
//  {
//    do {
//      let stream = try await service.startStreamedChat(resource: resource, parameters: parameters)
//      return AsyncThrowingStream { continuation in
//        let task = Task {
//          do {
//            for try await result in stream {
//              if let choice = result.choices.first {
//                if choice.finishReason == nil {
//                  let content = choice.delta.content ?? ""
//                  self.addToResponseAccumulator(text: content)
//                  continuation.yield(content)
//                } else {
//                  break
//                }
//              }
//            }
//            self.addAccumulatedResponseToMessageHistory(assistantId: assistantId)
//            continuation.finish()
//          } catch {
//            logErrorAndResetAccumulator(error)
//            continuation.finish(throwing: error)
//          }
//        }
//        continuation.onTermination = { @Sendable termination in
//          task.cancel()
//          if case .cancelled = termination {
//            Task {
//              await self.addAccumulatedResponseToMessageHistory(assistantId: assistantId)
//            }
//          }
//        }
//      }
//    } catch {
//      logErrorAndResetAccumulator(error)
//      throw ChatServiceError.error(error)
//    }
//  }
//
//  /// Tracks the history of assistant messages.
//  ///
//  /// - Parameter assistantId: The identifier used to track which assistant is sending the message,
//  ///   allowing for the correct association of responses with the corresponding assistant.
//  private func addAccumulatedResponseToMessageHistory() {
//    if let accumulator = streamingResponseAccumulator {
//      // Append the accumulated response to the message history, including the assistant's ID if available.
////      messagesHistory.append(.init(role: .assistant, content: .text(accumulator)))
//      streamingResponseAccumulator = nil
//    }
//  }
//
//  /// Tracks the streamed text of a message response.
//  private func addToResponseAccumulator(text: String) {
//    if let accumulator = streamingResponseAccumulator {
//      streamingResponseAccumulator = accumulator + text
//    } else {
//      streamingResponseAccumulator = text
//    }
//  }
//
//  private func logErrorAndResetAccumulator(_ error: Error) {
//    streamingResponseAccumulator = nil
//  }
//}
