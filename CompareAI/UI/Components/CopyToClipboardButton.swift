//
//  CopyToClipboardButton.swift
//  CompareAI
//
//  Created by James Rochabrun on 6/21/24.
//

import Foundation
import SwiftUI

struct CopyToClipboardButton: View {

  // MARK: Internal

  var textToCopy: String

  var body: some View {
    Button {
      let pasteboard = NSPasteboard.general
      pasteboard.clearContents()
      pasteboard.setString(textToCopy, forType: .string)
      copiedToClipboard = true
    } label: {
      Image(systemName: "doc.on.doc")
        .resizable()
        .frame(width: Sizes.imageButtonSize.width, height: Sizes.imageButtonSize.height)
        .font(.title)
    }
    .confirmationDialog("Copied to Clipboard", isPresented: $copiedToClipboard) { }
  }

  // MARK: Private

  @Environment(\.colorScheme) private var colorScheme
  @State private var copiedToClipboard = false
}

#Preview {
  CopyToClipboardButton(textToCopy: "Some code")
}
