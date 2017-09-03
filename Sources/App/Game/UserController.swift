//
//  UserController.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/19/17.
//
//

import Foundation
import Vapor

class UserController {
    static let instance = UserController()

    private(set) var activeUsers: Set<User> = []
    private(set) var userSockets: [User: WebSocket] = [:]

    func registerUser(_ user: User, with socket: WebSocket) {
        activeUsers.insert(user)

        userSockets[user] = socket

        Logger.info("Registered user \(user.identifier)")
    }
}
