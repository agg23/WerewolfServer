//
//  WebSocket+JSON.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

extension WebSocket {
    func send(json: JSON, user: User) {
        do {
            let bytes = try json.makeBytes()
            let string = bytes.makeString()
            Logger.info("Sending to user \(user.id): \(string)")
            try self.send(string)
        } catch {
            // TODO: Handle
            Logger.error("Socket sending error")
        }
    }
}
