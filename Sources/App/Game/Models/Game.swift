//
//  Game.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/19/17.
//
//

import Vapor
import FluentProvider

class Game: Hashable {
    let id: Int
    var name: String?
    var password: String?
    private(set) var charactersInPlay: [WWCharacter.Type] = []

    var users: Set<User> = []

    var assignments: [User: WWCharacter] = [:]

    var internalGame: WWGame

    init(id: Int) {
        self.id = id

        self.internalGame = WWGame(name: String(id))
    }

    func registerUser(_ user: User) {
        users.insert(user)

        user.game = self
    }

    func removeUser(_ user: User) {
        users.remove(user)

        user.game = nil
    }

    // MARK: - Hashable

    var hashValue: Int {
        return id
    }

    static func ==(lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }
}
