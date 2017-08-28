//
//  SocketController.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/18/17.
//
//

import Foundation
import Vapor

class SocketData {
    var user: User?
}

class SocketController {
    let gameController = GameController.instance
    let authenticationController = AuthenticationController()

    var version: String!

    func socketHandler(_ request: Request, socket: WebSocket) throws {
        Logger.info("Opened connection")

        let socketData = SocketData()

        socket.onText = { (socket: WebSocket, text: String) throws in
            try self.socketResponse(socket: socket, text: text, socketData: socketData)
        }

        socket.onClose = { (socket: WebSocket, code: UInt16?, reason: String?, clean: Bool) throws in
            guard let user = socketData.user else {
                Logger.info("Socket closed for unauthenticated user")
                return
            }

            Logger.info("Socket closed for user \(user.id)")
            // Disconnect user
            do {
                try self.disconnectUser(user)
            } catch {
                // Do nothing
            }
        }

        socket.onPing = { (socket: WebSocket, frame: Bytes) in
            Logger.info("Ping")
        }

        sendStatus(.success, task: "connect", data: nil, message: nil, socket: socket, socketData: socketData)
    }

    func socketResponse(socket: WebSocket, text: String, socketData: SocketData) throws {
        if text == "__ping__" {
            // Send pong response
            try socket.send("__pong__")
            return
        }

        if let user = socketData.user {
            Logger.info("Received message from user \(user.id): \(text)")
        } else {
            Logger.info("Received message from unauthenticated user: \(text)")
        }

        var json: JSON = JSON.null

        do {
            json = try JSON(bytes: Array(text.utf8))
            let data = try parse(json: json, socket: socket, socketData: socketData)
            sendStatus(.success, task: json["command"]?.string, data: data, message: nil, socket: socket, socketData: socketData)
        } catch ParseError.missingData(let message) {
            sendStatus(.failure, task: json["command"]?.string, data: nil, message: "Missing required field '" + message + "'", socket: socket, socketData: socketData)
        } catch ParseError.malformedData(let message) {
            sendStatus(.failure, task: json["command"]?.string, data: nil, message: "Malformed field '" + message + "'", socket: socket, socketData: socketData)
        } catch ParseError.invalidCommand {
            sendStatus(.failure, task: json["command"]?.string, data: nil, message: "Invalid command", socket: socket, socketData: socketData)
        } catch let error as GameController.GameError where GameController.GameError.allValues.contains(error) {
            sendStatus(.failure, task: json["command"]?.string, data: nil, message: GameController.GameError.message(for: error), socket: socket, socketData: socketData)
        } catch let error as AuthenticationController.AuthenticationError where AuthenticationController.AuthenticationError.allValues.contains(error) {
            sendStatus(.failure, task: json["command"]?.string, data: nil, message: AuthenticationController.AuthenticationError.message(for: error), socket: socket, socketData: socketData)
        } catch {
            sendStatus(.failure, task: nil, data: nil, message: "Unknown message", socket: socket, socketData: socketData)
        }
    }

    func parse(json: JSON, socket: WebSocket, socketData: SocketData) throws -> JSON? {
        guard let command = json["command"]?.string else {
            throw ParseError.invalidCommand
        }

        if command == "login" {
            return try authenticationController.login(socketController: self, json: json, socket: socket, socketData: socketData)
        }

        guard let user = socketData.user else {
            throw AuthenticationController.AuthenticationError.authRequired
        }

        switch command {
        // User
        case "setNickname":
            return try setNickname(json: json, socket: socket, user: user)

        // Game
        case "hostGame":
            return try hostGame(json: json, socket: socket, user: user)
        case "joinGame":
            return try joinGame(json: json, socket: socket, user: user)

        case "ready":
            try markUserReady(socket: socket, user: user)
        case "select":
            try selectUserIndexes(json: json, socket: socket, user: user)
        default:
            throw ParseError.invalidCommand
        }

        return nil
    }
}

// MARK: - JSON Messages
extension SocketController {
    enum ParseError: Error {
        case invalidCommand
        case missingData(String)
        case malformedData(String)
    }

    enum MessageStatus: String {
        case success = "success"
        case failure = "failure"
    }

    func sendStatus(_ status: MessageStatus, task: String?, data: JSON?, message: String?, socket: WebSocket, socketData: SocketData) {
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
        socket.send(json: json, socketData: socketData)
    }

    // MARK: - User Functions

    func setNickname(json: JSON, socket: WebSocket, user: User) throws -> JSON? {
        guard let nickname = json["nickname"]?.string else {
            throw ParseError.missingData("nickname")
        }
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
            throw ParseError.missingData("name")
        }

        guard let characterNames = json["inPlay"]?.array else {
            throw ParseError.missingData("inPlay")
        }

        var charactersInPlay: [GameCharacter.Type] = []

        for characterName in characterNames {
            if let string = characterName.string,
                let character = gameController.character(for: string) {
                charactersInPlay.append(character)
            } else {
                throw ParseError.malformedData("inPlay")
            }
        }

        let game = gameController.createGame()

        game.name = name
        game.password = json["password"]?.string
        game.charactersInPlay = charactersInPlay

        gameController.registerGame(game)

        try gameController.joinGame(game, password: game.password, user: user)

        var data = JSON()
        data["id"] = JSON(game.id)
        return data
    }

    func joinGame(json: JSON, socket: WebSocket, user: User) throws -> JSON? {
        guard let id = json["id"]?.int else {
            throw ParseError.missingData("id")
        }

        let password = json["password"]?.string

        let game = try gameController.game(with: id)

        try gameController.joinGame(game, password: password, user: user)

        var data = JSON()
        data["id"] = JSON(game.id)
        return data
    }

    func markUserReady(socket: WebSocket, user: User) throws {
        guard let game = user.game else {
            throw GameController.GameError.userNotInGame
        }

        game.readyUser(user)

        let _ = gameController.checkGameStatus(game)
        gameController.updateGameStatus(game)
    }

    func selectUserIndexes(json: JSON, socket: WebSocket, user: User) throws {
        guard let typeString = json["type"]?.string else {
            throw ParseError.missingData("type")
        }

        guard let type = Action.SelectionType(rawValue: typeString) else {
            throw ParseError.malformedData("type")
        }

        let selectionsJson = json["selections"]?.array
        let selections = try selectionsJson?.map({(value: JSON) -> User in
            if let id = value.int,
                let user = user.game?.users[id] {
                return user
            } else {
                throw ParseError.malformedData("selections")
            }
        })

        let rotation = Action.Rotation(rawValue: json["rotation"]?.string ?? "")

        try gameController.user(user, selectedType: type, selections: selections, rotation: rotation)
    }
}
