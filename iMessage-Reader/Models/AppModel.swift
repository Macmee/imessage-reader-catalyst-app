//
//  AppModel.swift
//  iMessage-Reader
//
//  Created by David Zorychta on 10/6/22.
//

import SwiftUI

class AppModel: ObservableObject {
  let messageStore = MessageStore()
  let bridge = AppKitBridgeCatalyst()
}
