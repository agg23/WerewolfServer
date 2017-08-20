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
            try self.send(bytes.makeString())
        } catch {
            // TODO: Handle
            print("Socket sending error")
        }
    }
}
