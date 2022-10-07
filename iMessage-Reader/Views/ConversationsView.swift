//
//  ConversationsView.swift
//  iMessage-Reader
//
//  Created by David Zorychta on 10/6/22.
//

import Combine
import SwiftUI

struct ConversationsView: View {
  
  private enum Constant {
    static let errorPadding: Double = 40
    static let errorSFSymbolName = "exclamationmark.triangle"
    static let errorSFSymbolSize: Double = 60
    static let errorRetryText = "Retry"
    static let initialLoadText = "Click to Load Messages"
    static let mainListTitle = "Conversations"
  }
  
  private let appBecameActiveNotification = NotificationCenter.default.publisher(for: .catalystAppBecameActive)
  
  @EnvironmentObject var appModel: AppModel
  @Environment(\.scenePhase) var scenePhase
  @StateObject private var model = MessagesModel()

  var body: some View {

    switch model.state {

    case .loading:
      ProgressView()

    case .error(let message):
      VStack(spacing: Constant.errorPadding) {
        Image(systemName: Constant.errorSFSymbolName).foregroundColor(Color.red).font(.system(size: Constant.errorSFSymbolSize))
        Text(message.rawValue).foregroundColor(Color.red)
        Button(Constant.errorRetryText) {
          model.getMessages(appModel: appModel)
        }
      }

    case .empty:
      Button(Constant.initialLoadText) {
        model.getMessages(appModel: appModel)
      }
      .onAppear() {
        model.getMessagesIfBookmarkExists(appModel: appModel)
      }

    case .ready:
      NavigationView {
        List(model.latestMessages) { message in
          NavigationLink {
            ConversationView(messages: model.getMessages(forPhoneNumber: message.other_phone_number))
              .environmentObject(model)
              .navigationBarTitle(message.other_phone_number, displayMode: .inline)
          } label: {
            VStack(alignment: .leading) {
              Text(message.other_phone_number).font(Font.headline.weight(.bold))
              Text(message.text).font(Font.headline.weight(.light))
            }
          }
        }
        .navigationBarTitle(Text(Constant.mainListTitle))
        .onReceive(appBecameActiveNotification) { _ in
          model.getMessagesIfBookmarkExists(appModel: appModel)
        }
      }

    }
  }
}
