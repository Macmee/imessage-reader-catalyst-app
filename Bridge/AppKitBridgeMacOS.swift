//
//  AppKitBridgeMacOS.swift
//  iMessage-Reader
//
//  Created by David Zorychta on 9/30/22.
//

// We are a mac catalyst app. When running on MacOS we are both inside a sandbox and have no proper access to
// AppKit.
//
// the iMessages chat.db file is in the library folder, outside of the sandbox. We can't access it!
//
// But if we were a MacApp we could show the user a File Selector pane and they could choose it (NSOpenPanel).
//
// We need AppKit from within our Catalyst app to do this. So we created a new target thats a mac app bundle
// and we embed it into our catalyst app here.
// (see: https://betterprogramming.pub/how-to-access-the-appkit-api-from-mac-catalyst-apps-2184527020b5)
// we then dynamically load the bundle at runtime from our catalyst app, and it then lets us access AppKit stuff
// from a mac catalyst app. Now we can call into NSOpenPanel and show users a file picker for MacOS properly.
//
// We then have the problem of needing to read the chat.db file in the library folder on your mac. Our app is
// running in a sandbox. But after the user picks the chat.db file with the file picker, we can copy it
// into a sandbox folder where our catalyst app can access it!!

import AppKit
import Combine
import Foundation

fileprivate extension FileManager {
  
  @discardableResult
  static func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
    do {
      if FileManager.default.fileExists(atPath: dstURL.path) {
        try FileManager.default.removeItem(at: dstURL)
      }
      try FileManager.default.copyItem(at: srcURL, to: dstURL)
    } catch (let error) {
      print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
      return false
    }
    return true
  }
  
}

class AppKitBridgeMacOS: NSObject, AppKitBridgeProtocol {
  
  private enum Constant {
    static let permanentFileAccessBookmarkNSUDKey = "permanentFileAccessBookmarkNSUDKey"
  }
  
  required override init() {
    super.init()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appBecameActive),
      name: NSApplication.didBecomeActiveNotification,
      object: NSApplication.shared
    )
  }
  
  @objc func appBecameActive() {
    NotificationCenter.default.post(name: .catalystAppBecameActive, object: nil)
  }
  
  func saveToFile(data: String) {
    let savePanel = NSSavePanel()
    savePanel.canCreateDirectories = false
    let user = NSUserName()
    savePanel.directoryURL = NSURL.fileURL(withPath: "/Users/\(user)/Downloads")
    savePanel.showsTagField = false
    savePanel.nameFieldStringValue = "iMessage-Data-\(Date().ISO8601Format().components(separatedBy: "T").first ?? "").csv"
    savePanel.begin { (result) in
      if result.rawValue == NSApplication.ModalResponse.OK.rawValue, let url = savePanel.url {
        try? data.write(to: url, atomically: true, encoding: String.Encoding.utf8)
      }
    }
  }
  
  private var tempChatFile: URL? {
    let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    return directory?.appendingPathComponent("chatDbcopy.db")
  }
  
  lazy private(set) var permanentFileBookmarkUrl: URL? = {
    var isStale = false
    if let permanentFileAccessBookmark = UserDefaults.standard.data(forKey: Constant.permanentFileAccessBookmarkNSUDKey),
       let newUrl = try? URL(resolvingBookmarkData: permanentFileAccessBookmark,
                             options: .withSecurityScope,
                             relativeTo: nil,
                             bookmarkDataIsStale: &isStale),
       !isStale && newUrl.startAccessingSecurityScopedResource() {
      return newUrl
    }
    return nil
  }()
  
  func openChatFileOnDisk(_ callback: @escaping (URL?) -> ()) {
    guard let tempChatFile = tempChatFile else {
      callback(nil)
      return
    }
    // perhaps we opened the chat.db file in a previous app session, and can re-use our bookmark to it!
    if let permanentFileBookmarkUrl = permanentFileBookmarkUrl {
      FileManager.secureCopyItem(at: permanentFileBookmarkUrl, to: tempChatFile)
      callback(tempChatFile)
      return
    }
    // show a file picker and get the user to choose the file
    let openPanel = NSOpenPanel()
    openPanel.message = "1️⃣ Choose chat.db Below"
    openPanel.prompt = "2️⃣ Then Click Here"
    openPanel.allowedFileTypes = ["db"]
    openPanel.allowsOtherFileTypes = false
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = false
    let user = NSUserName()
    openPanel.directoryURL = NSURL.fileURL(withPath: "/Users/\(user)/Library/Messages")
    openPanel.begin { (result) -> Void in
      guard let url = openPanel.url, result.rawValue == NSApplication.ModalResponse.OK.rawValue, url.path.hasSuffix("chat.db") else {
        callback(nil)
        return
      }
      if let permanentFileAccessBookmark = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
        UserDefaults.standard.set(permanentFileAccessBookmark, forKey: Constant.permanentFileAccessBookmarkNSUDKey)
      }
      FileManager.secureCopyItem(at: url, to: tempChatFile)
      callback(tempChatFile)
    }
  }
}
