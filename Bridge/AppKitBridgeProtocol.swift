//
//  AppKitBridgeProtocol.swift
//  iMessage-Reader
//
//  Created by David Zorychta on 10/6/22.
//

import Foundation

@objc(AppKitBridgeProtocol)
protocol AppKitBridgeProtocol: NSObjectProtocol {
  init()
  func saveToFile(data: String)
  func openChatFileOnDisk(_ callback: @escaping (URL?) -> ())
  var permanentFileBookmarkUrl: URL? { get }
}
