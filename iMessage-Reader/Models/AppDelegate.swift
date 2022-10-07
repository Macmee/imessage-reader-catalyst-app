//
//  AppDelegate.swift
//  iMessage-Reader
//
//  Created by David Zorychta on 10/6/22.
//

import SwiftUI

fileprivate var mainWindowMinSize: CGSize {
  if UIScreen.main.bounds.size.width >= 1600 && UIScreen.main.bounds.size.height >= 1100 {
    return CGSize(width: 1600, height: 1100)
  }
  return CGSize(width: 1, height: 1)
}

class FSSceneDelegate: NSObject, UIWindowSceneDelegate {
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let _ = (scene as? UIWindowScene) else { return }
    UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
      windowScene.sizeRestrictions?.minimumSize = mainWindowMinSize
    }
  }
}


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
      windowScene.sizeRestrictions?.minimumSize = mainWindowMinSize
    }
    return true
  }
  
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    sceneConfig.delegateClass = FSSceneDelegate.self
    return sceneConfig
  }

}
