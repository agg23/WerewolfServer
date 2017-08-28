//
//  AuthenticationController.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/27/17.
//
//

import Foundation
import BCrypt
import FluentProvider

class AuthenticationController {
    let hasher = BCryptHasher()

    enum AuthenticationError: Error {
        case authRequired
        case authFailed
        case registrationFailed
        case invalidUser

        static let allValues: [AuthenticationError] = [.authRequired, .authFailed, .registrationFailed, .invalidUser]

        static func message(for error: AuthenticationError) -> String {
            switch error {
            case .authRequired:
                return "Authentication is required to complete this command"
            case .authFailed:
                return "Authentication failed. Password is invalid"
            case .registrationFailed:
                return "Registration failed"
            case .invalidUser:
                return "User does not exist"
            }
        }
    }

    func login(socketController: SocketController, json: JSON, socket: WebSocket, socketData: SocketData) throws -> JSON? {
        guard let username = json["username"]?.string else {
            throw SocketController.ParseError.missingData("username")
        }

        guard let password = json["password"]?.string else {
            throw SocketController.ParseError.missingData("password")
        }

        var userRow: User? = nil

        do {
            userRow = try User.makeQuery().filter("username", .equals, username).first()
        } catch {
            // Do nothing
        }

        guard let user = userRow else {
            throw AuthenticationError.invalidUser
        }

        var passwordValidated = false

        do {
            passwordValidated = try hasher.check(password.bytes, matchesHash: user.passwordHash.bytes)
        } catch {
            passwordValidated = false
        }

        if !passwordValidated {
            throw AuthenticationError.authFailed
        }

        return completeLogin(socketController: socketController, socket: socket, socketData: socketData, user: user)
    }

    func register(socketController: SocketController, json: JSON, socket: WebSocket, socketData: SocketData) throws -> JSON? {
        guard let username = json["username"]?.string else {
            throw SocketController.ParseError.missingData("username")
        }

        guard let password = json["password"]?.string else {
            throw SocketController.ParseError.missingData("password")
        }

        let user: User

        do {
            let hashedPassword = try hasher.make(password)

            user = User(username: username, passwordHash: hashedPassword.makeString(), nickname: json["nickname"]?.string)

            try user.save()
        } catch {
            Logger.error("Database saving error: \(error)")
            throw AuthenticationError.registrationFailed
        }

        return completeLogin(socketController: socketController, socket: socket, socketData: socketData, user: user)
    }

    // MARK: - Convenience

    func completeLogin(socketController: SocketController, socket: WebSocket, socketData: SocketData, user: User) -> JSON {
        // Authentication complete
        socketData.user = user
        UserController.instance.registerUser(user, with: socket)

        var json = JSON()
        json["id"] = JSON(user.identifier)
        json["username"] = JSON(user.username)
        json["serverVersion"] = JSON(socketController.version)
        json["availableCharacters"] = JSON(GameController.instance.availableCharacters.map({ return JSON($0.name) }))

        return json
    }
}
