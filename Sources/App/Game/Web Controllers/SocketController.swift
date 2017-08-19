//
//  SocketController.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/18/17.
//
//

import Foundation
import Vapor

class SocketController {
    func socketHandler(_ request: Request, socket: WebSocket) throws {
        socket.onText = socketResponse(ws:text:)
    }

    func socketResponse(ws: WebSocket, text: String) throws {
        print("Received message \(text)")
        print(ws)
    }
}
