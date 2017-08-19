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

    var activeUsers: Set<User> = []
    var userSockets: [User: WebSocket] = [:]
    var lowestAvailableId: Int = 0

    func createUser() -> User {
        return User(id: nextAvailableId())
    }

    func registerUser(_ user: User, with socket: WebSocket) {
        activeUsers.insert(user)

        userSockets[user] = socket

        print("Registered user \(user.id)")
    }

    func nextAvailableId() -> Int {
        let id = lowestAvailableId
        lowestAvailableId += 1
        return id
    }
}
