//
//  File.swift
//  CompareAI
//
//  Created by James Rochabrun on 7/5/24.
//

import Foundation
import SwiftUI

enum Prompts {
   
   static let analyzingSystemPrompt = """
                                    You ar an AI agent, your job is to orchestrate tasks, you will get responses from different LLM providers, such OpenAI, Anthropic etc. your job is to analyze each answer carefully and determine which provider gave the best answer for a given prompt. Step 1: you will list the providers and later say which one is the best. Step 2: you need to take the best of all answers and construct one final super answer
"""
   
   static func analyzeUsersPrompt(
      _ prompt: String,
      content: String)
      -> String
   {
      """
      Prompt: \(prompt)
      
      Content: \(content)
      """
   }
   
   static func printHelper(context: String, content: String) {
      print("---------Begining Context \(context)----------\n")
      print(content)
      print("---------End Context \(context)---------------\n")
   }
}
