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

        sendStatus(.success, task: "connect", socket: socket)
    }

    func socketResponse(socket: WebSocket, text: String, user: User) throws {
        print("Received message \(text)")

        let json = try JSON(bytes: Array(text.utf8))
        let status: MessageStatus = parse(json: json, socket: socket, user: user) ? .success : .failure
        sendStatus(status, task: json["command"]?.string, socket: socket)
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
        // User
        case "setNickname":
            return setNickname(json: json, socket: socket, user: user)

        // Game
        case "hostGame":
            return hostGame(json: json, socket: socket, user: user)
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

    func sendStatus(_ status: MessageStatus, task: String?, socket: WebSocket) {
        var json = JSON()
        json["command"] = "response"

        let taskJson: JSON

        if let task = task {
            taskJson = JSON(task)
        } else {
            taskJson = JSON.null
        }

        json["task"] = taskJson
        json["status"] = JSON(status.rawValue)
        send(json, socket: socket)
    }

    // MARK: - User Functions

    func setNickname(json: JSON, socket: WebSocket, user: User) -> Bool {
        let nickname = json["nickname"]?.string
        user.nickname = nickname

        return true
    }

    // MARK: - Game Functions

    func hostGame(json: JSON, socket: WebSocket, user: User) -> Bool {
        guard let name = json["name"]?.string else {
            return false
        }

        let game = GameController.instance.createGame()

        game.name = name

        GameController.instance.registerGame(game)

        game.registerUser(user)

        return true
    }
}
