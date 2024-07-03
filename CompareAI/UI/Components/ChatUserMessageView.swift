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
         .textSelection(.enabled)
         .padding(.horizontal)
         .padding(.vertical, 8)
         .background(Color.black.opacity(0.2))
         .clipShape(Capsule())
         .overlay(
            Capsule()
               .foregroundColor(.clear)
         )
   }
}

#Preview {
   ChatUserMessageView(text: "Who is Darth vader?")
}
