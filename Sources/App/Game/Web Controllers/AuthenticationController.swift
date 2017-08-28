//
//  AuthenticationController.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/27/17.
//
//

import Foundation
import FluentProvider

class AuthenticationController {
    enum AuthenticationError: Error {
        case authRequired
        case authFailed
        case invalidUser

        static let allValues: [AuthenticationError] = [.authRequired, .authFailed, .invalidUser]

        static func message(for error: AuthenticationError) -> String {
            switch error {
            case .authRequired:
                return "Authentication is required to complete this command"
            case .authFailed:
                return "Authentication failed. Password is invalid"
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

        // TODO: Salt and hash passwords
        guard user.password == password else {
            throw AuthenticationError.authFailed
        }

        // Authentication complete
        socketData.user = user

        var json = JSON()
        json["id"] = JSON(user.identifier)
        json["serverVersion"] = JSON(socketController.version)
        json["availableCharacters"] = JSON(GameController.instance.availableCharacters.map({ return JSON($0.name) }))

        return json
    }
}
