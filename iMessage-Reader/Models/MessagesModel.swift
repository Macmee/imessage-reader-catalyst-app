//
//  MessagesModel.swift
//  iMessage-Reader
//
//  Created by David Zorychta on 10/6/22.
//

import Combine
import SwiftUI

class MessagesModel: ObservableObject {
  
  private var appModel: AppModel?
  
  enum Error: String {
    case failedOpeningChatFile = "Uh oh, we couldn't open your chat.db file"
    case failedGettingMessages = "Uh oh, we failed to retrieve your messages"
  }
  
  enum State: Equatable {
    case empty
    case loading
    case ready
    case error(message: Error)
  }
  
  @Published private(set) var messages: [MessageStore.Message] = []
  @Published private(set) var latestMessages: [MessageStore.Message] = []
  @Published private(set) var state: State = .empty
  
  func getMessages(appModel: AppModel) {
    self.appModel = appModel
    state = .loading
    appModel.bridge.appKit?.openChatFileOnDisk() { [weak self] url in
      guard let self = self, let url = url else {
        self?.state = .error(message: .failedOpeningChatFile)
        return
      }
      guard let messages = appModel.messageStore.getAllMessages(url: url) else {
        self.state = .error(message: .failedGettingMessages)
        return
      }
      self.messages = messages
      var seenConversations = Set<String>()
      self.latestMessages = self.messages.reversed().reduce(into: [MessageStore.Message]()) { (latestMessages, message) in
        if seenConversations.contains(message.other_phone_number) { return }
        latestMessages.append(message)
        seenConversations.insert(message.other_phone_number)
      }
      self.state = .ready
    }
  }
  
  func getMessages(forPhoneNumber phoneNumber: String) -> [MessageStore.Message] {
    messages.filter { $0.other_phone_number == phoneNumber }.reversed()
  }
  
  func getMessagesIfBookmarkExists(appModel: AppModel) {
    if appModel.bridge.appKit?.permanentFileBookmarkUrl != nil {
      getMessages(appModel: appModel)
    }
  }
  
}
