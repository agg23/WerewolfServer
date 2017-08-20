//
//  WebSocket+JSON.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

extension WebSocket {
    func send(json: JSON) {
        do {
            let bytes = try json.makeBytes()
            let string = bytes.makeString()
            Logger.info("Sending: \(string)")
            try self.send(string)
        } catch {
            // TODO: Handle
            Logger.error("Socket sending error")
        }
    }
}
