//
//  ChatUserMessageView.swift
//  CompareAI
//
//  Created by James Rochabrun on 7/1/24.
//

import Foundation
import SwiftUI

struct ChatUserMessageView: View {
   
   let text: String
   
   var body: some View {
      Text(text)
         .fixedSize(horizontal: false, vertical: true)
         .textSelection(.enabled)
         .padding(.horizontal)
         .padding(.vertical, 8)
         .background(Color.black.opacity(0.2))
         .clipShape(Capsule())
         .overlay(
            Capsule()
               .foregroundColor(.clear)
         )
         .frame(maxWidth: .infinity, alignment: .trailing)
         .padding()
   }
}

#Preview {
   ChatUserMessageView(text: "I'm just an AI, so I don't have emotions or feelings like humans do. I'm simply a computer program designed to process and respond to natural language input, which allows me to chat with you! I'm always and ready to help answer your questions or engage in conversation whenever you need it. How about you?")
}
