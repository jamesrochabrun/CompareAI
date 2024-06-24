//
//  ChatMessageView.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/22/24.
//

import Foundation
import SwiftUI

struct ChatMessageView: View {
   
   var content: MultipleContent
   
   var body: some View {
      HStack {
         ForEach(content.content) { response in
            CodeBlockView(header: response.provider.rawValue, text: response.response)
         }
      }
   }
}
