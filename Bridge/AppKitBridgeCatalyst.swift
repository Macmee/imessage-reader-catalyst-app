//
//  AppKitBridgeCatalyst.swift
//  iMessage-Reader
//
//  Created by David Zorychta on 10/6/22.
//

import Foundation

class AppKitBridgeCatalyst {
  
  private enum Constant {
    static let bundle = "AppKitBridge.bundle"
    static let className = "AppKitBridge.AppKitBridgeMacOS"
  }

  private(set) var appKit: AppKitBridgeProtocol?

  init() {
    guard let bundleURL = Bundle.main.builtInPlugInsURL?
      .appendingPathComponent(Constant.bundle) else { return }
    guard let bundle = Bundle(url: bundleURL) else { return }
    guard let pluginClass = bundle.classNamed(Constant.className) as? AppKitBridgeProtocol.Type else { return }
    appKit = pluginClass.init()
  }
  
}

