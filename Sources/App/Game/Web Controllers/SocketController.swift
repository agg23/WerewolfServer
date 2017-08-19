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
        print("Opened connection")

        let user = UserController.instance.createUser()
        UserController.instance.registerUser(user, with: socket)

        socket.onText = { (socket: WebSocket, text: String) throws in
            try self.socketResponse(socket: socket, text: text, user: user)
        }

        sendStatus(.success, socket: socket)
    }

    func socketResponse(socket: WebSocket, text: String, user: User) throws {
        print("Received message \(text)")

        let json = try JSON(bytes: Array(text.utf8))
        let status: MessageStatus = parse(json: json, socket: socket, user: user) ? .success : .failure
        sendStatus(status, socket: socket)
    }

    func send(_ json: JSON, socket: WebSocket) {
        do {
            let bytes = try json.makeBytes()
            try socket.send(bytes.makeString())
        } catch {
            // TODO: Handle
            print("Socket sending error")
        }
    }

    func parse(json: JSON, socket: WebSocket, user: User) -> Bool {
        guard let command = json["command"]?.string else {
            return false
        }

        switch command {
        case "setNickname":
            return setNickname(json: json, socket: socket, user: user)
        default:
            return false
        }
    }
}

// MARK: - JSON Messages
extension SocketController {
    enum MessageStatus: String {
        case success = "success"
        case failure = "failure"
    }

    func sendStatus(_ status: MessageStatus, socket: WebSocket) {
        var json = JSON()
        json["command"] = "response"
        json["status"] = JSON(status.rawValue)
        send(json, socket: socket)
    }

    func setNickname(json: JSON, socket: WebSocket, user: User) -> Bool {
        let nickname = json["nickname"]?.string
        user.nickname = nickname

        return true
    }
}
