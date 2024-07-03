//
//  LLMProviderSelectionView.swift
//  CompareAI
//
//  Created by James Rochabrun on 7/2/24.
//

import Foundation
import SwiftUI

// MARK: LLMProviderSelectionView

struct LLMProviderSelectionView: View {
   
   let availableProviders: [LLMProvider]
   
   @Binding var selectedProviders: [LLMProvider]
   
   var body: some View {
      VStack(alignment: .leading) {
         ForEach(availableProviders) { provider in
            CheckboxView(
               title: provider.rawValue,
               isChecked: Binding(
                  get: {
                     selectedProviders.contains(provider)
                  },
                  set: { isSelected in
                     if isSelected {
                        selectedProviders.append(provider)
                     } else {
                        selectedProviders.removeAll { $0 == provider }
                     }
                  }
               )
            )
         }
      }
      .padding()
   }
}

// MARK: CheckboxView

struct CheckboxView: View {
   
   var title: String
   @Binding var isChecked: Bool
   
   var body: some View {
      HStack {
         Image(systemName: isChecked ? "checkmark.square" : "square")
            .onTapGesture {
               isChecked.toggle()
            }
         Text(title)
            .font(.body)
            .onTapGesture {
               isChecked.toggle()
            }
      }
   }
}
