//
//  MessageStore.swift
//  iMessage-Reader
//
//  Created by David Zorychta on 10/6/22.
//

import Combine
import SwiftUI
import SQLite

class MessageStore {
  
  struct Message: Identifiable {
    let id: Int
    let text: String
    let time: Int
    let other_phone_number: String
    var sender: Bool
    var date: Date {
      Date(timeIntervalSince1970: Double((time / 1000000000) + 978307200))
    }
  }
  
  func getAllMessages(url: URL) -> [Message]? {
    do {
      var messages = [Message]()
      let db = try Connection(url.path)
      for joinRow in try db.prepare("SELECT chat_id FROM chat_message_join GROUP BY chat_id ORDER BY message_date DESC") {
        guard let chatId = joinRow[0] else { continue }
        for row in try db.prepare("SELECT text, ROWID, date, (SELECT chat_identifier FROM chat WHERE chat.ROWID = \"\(chatId)\") as chat_identifier, is_sent FROM message WHERE ROWID IN (SELECT message_id FROM chat_message_join WHERE chat_id = \"\(chatId)\") ORDER BY date DESC LIMIT 100") {
          messages.append(
            Message(
              id: Int("\(row[1] ?? "")") ?? 0,
              text: "\(row[0] ?? "")",
              time: Int("\(row[2] ?? "")") ?? 0,
              other_phone_number: "\(row[3] ?? "")",
              sender: "\(row[4] ?? "0")" == "1"
            )
          )
        }
      }
      messages.sort(by: { a, b in a.time < b.time })
      return messages
    } catch {
      print(error)
    }
    return nil
  }
  
}

