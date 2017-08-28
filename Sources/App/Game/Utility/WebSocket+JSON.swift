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
        let data = SocketData()
        data.user = user
        send(json: json, socketData: data)
    }

    func send(json: JSON, socketData: SocketData) {
        do {
            let bytes = try json.makeBytes()
            let string = bytes.makeString()
            if let user = socketData.user {
                Logger.info("Sending to user \(user.id): \(string)")
            } else {
                Logger.info("Sending to unauthenticated user: \(string)")
            }
            try self.send(string)
        } catch {
            // TODO: Handle
            Logger.error("Socket sending error")
        }
    }
}
