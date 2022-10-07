//
//  AppView.swift
//  iMessage-Reader
//
//  Created by David Zorychta on 10/6/22.
//

import SwiftUI

@main
struct AppView: App {
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @StateObject var model = AppModel()
  
  var body: some Scene {
    WindowGroup {
      ConversationsView()
        .environmentObject(model)
    }
  }
}

