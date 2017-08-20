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
    let gameController = GameController.instance

    func socketHandler(_ request: Request, socket: WebSocket) throws {
        print("Opened connection")

        let user = UserController.instance.createUser()
        UserController.instance.registerUser(user, with: socket)

        socket.onText = { (socket: WebSocket, text: String) throws in
            try self.socketResponse(socket: socket, text: text, user: user)
        }

        socket.onClose = { (socket: WebSocket, code: UInt16?, reason: String?, clean: Bool) throws in
            print("Socket closed for user \(user.id)")
            // Disconnect user
            do {
                try self.disconnectUser(user)
            } catch {
                // Do nothing
            }
        }

        socket.onPing = { (socket: WebSocket, frame: Bytes) in
            print("Ping")
        }

        var json = JSON()
        json["id"] = JSON(user.id)

        sendStatus(.success, task: "connect", data: json, message: nil, socket: socket)
    }

    func socketResponse(socket: WebSocket, text: String, user: User) throws {
        if text == "__ping__" {
            // Send pong response
            try socket.send("__pong__")
            return
        }

        print("Received message \(text)")

        var json: JSON = JSON.null

        do {
            json = try JSON(bytes: Array(text.utf8))
            let data = try parse(json: json, socket: socket, user: user)
            sendStatus(.success, task: json["command"]?.string, data: data, message: nil, socket: socket)
        } catch ParseError.missingData(let message) {
            sendStatus(.failure, task: json["command"]?.string, data: nil, message: message, socket: socket)
        } catch ParseError.invalidCommand {
            sendStatus(.failure, task: json["command"]?.string, data: nil, message: "Invalid command", socket: socket)
        } catch let error as GameController.GameError where GameController.GameError.allValues.contains(error) {
            sendStatus(.failure, task: json["command"]?.string, data: nil, message: GameController.GameError.message(for: error), socket: socket)
        } catch {
            sendStatus(.failure, task: nil, data: nil, message: "Unknown message", socket: socket)
        }
    }

    func parse(json: JSON, socket: WebSocket, user: User) throws -> JSON? {
        guard let command = json["command"]?.string else {
            throw ParseError.invalidCommand
        }

        switch command {
        // User
        case "setNickname":
            return setNickname(json: json, socket: socket, user: user)

        // Game
        case "hostGame":
            return try hostGame(json: json, socket: socket, user: user)
        case "joinGame":
            return try joinGame(json: json, socket: socket, user: user)
        default:
            throw ParseError.invalidCommand
        }
    }
}

// MARK: - JSON Messages
extension SocketController {
    enum ParseError: Error {
        case invalidCommand
        case missingData(String)
    }

    enum MessageStatus: String {
        case success = "success"
        case failure = "failure"
    }

    func sendStatus(_ status: MessageStatus, task: String?, data: JSON?, message: String?, socket: WebSocket) {
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
        if let data = data {
            json["data"] = data
        }
        if let message = message {
            json["message"] = JSON(message)
        }
        socket.send(json: json)
    }

    // MARK: - User Functions

    func setNickname(json: JSON, socket: WebSocket, user: User) -> JSON? {
        let nickname = json["nickname"]?.string
        user.nickname = nickname

        if let game = user.game {
            gameController.updateGameStatus(game)
        }

        return nil
    }

    func disconnectUser(_ user: User) throws {
        try gameController.leaveGame(user: user)
    }

    // MARK: - Game Functions

    func hostGame(json: JSON, socket: WebSocket, user: User) throws -> JSON? {
        guard let name = json["name"]?.string else {
            throw ParseError.missingData("Missing field 'name'")
        }

        let game = gameController.createGame()

        game.name = name
        game.password = json["password"]?.string

        gameController.registerGame(game)

        try gameController.joinGame(game, password: game.password, user: user)

        var data = JSON()
        data["id"] = JSON(game.id)
        return data
    }

    func joinGame(json: JSON, socket: WebSocket, user: User) throws -> JSON? {
        guard let id = json["id"]?.int else {
            throw ParseError.missingData("Missing field 'id'")
        }

        let password = json["password"]?.string

        let game = try gameController.game(with: id)

        try gameController.joinGame(game, password: password, user: user)

        var data = JSON()
        data["id"] = JSON(game.id)
        return data
    }
}
