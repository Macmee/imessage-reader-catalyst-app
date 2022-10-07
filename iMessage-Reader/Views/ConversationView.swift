//
//  ConversationView.swift
//  iMessage-Reader
//
//  Created by David Zorychta on 10/6/22.
//

import Combine
import SwiftUI

fileprivate extension View {
  func flipVertical() -> some View {
    return rotationEffect(.radians(.pi)).scaleEffect(x: -1, y: 1, anchor: .center)
  }
}

struct ConversationView: View {
  @Environment(\.colorScheme) var colorScheme
  @State var messages: [MessageStore.Message]
  var body: some View {
    List(messages) { message in
      HStack {
        if message.sender {
          Spacer()
        }
        Text(message.text)
          .foregroundColor(colorScheme == .dark || message.sender ? .white : .black)
          .padding(10)
          .background(message.sender ? Color.accentColor : Color(hex: colorScheme == .dark ? 0x3b3b3d : 0xd1d1d1))
          .cornerRadius(15)
          .flipVertical()
      }
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
    }
    .flipVertical()
  }
}
