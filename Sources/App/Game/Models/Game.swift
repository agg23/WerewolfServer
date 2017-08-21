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
    enum State: String {
        case starting = "starting"
        case night = "night"
        case discussion = "discussion"
        case lobby = "lobby"
    }

    let id: Int
    var name: String?
    var password: String?

    var nonHumanCount: Int = 3

    var state: State

    var charactersInPlay: [GameCharacter.Type] = []

    var users: [User] = []
    var userIndexes: Set<Int> = []

    var userReady: [User: Bool] = [:]

    var assignments: [User: GameCharacter] = [:]

    private var lowestAvailableId: Int = 0

    init(id: Int) {
        self.id = id

        self.state = .lobby
    }

    func registerUser(_ user: User) {
        users.append(user)

        userReady[user] = false

        user.game = self
    }

    func removeUser(_ user: User) {
        if let index = users.index(of: user) {
            users.remove(at: index)
        }

        userReady.removeValue(forKey: user)

        user.game = nil
    }

    func readyUser(_ user: User) {
        userReady[user] = true
    }

    func unreadyUser(_ user: User) {
        userReady[user] = false
    }

    // MARK: - Utility

    func swap(firstUser first: Int, secondUser second: Int) {
        let firstUser = users[first]
        let secondUser = users[second]

        let temp = assignments[firstUser]
        let temp2 = assignments[secondUser]

        assignments[firstUser] = temp2
        assignments[secondUser] = temp
    }

    func mapCharactersToUsers(characters: [GameCharacter]) {
        guard characters.count >= users.count else {
            Logger.error("Not enough characters to satisfy users")
            return
        }

        for (i, user) in zip(users.indices, users) {
            let character = characters[i]
            assignments[user] = character
        }
    }

    func user(for character: GameCharacter) -> User? {
        let tuple = assignments.first(where: { return $0.value == character })
        return tuple?.key
    }

    func isHuman(with character: GameCharacter) -> Bool {
        guard let user = user(for: character) else {
            Logger.error("Character does not exist in this game")
            return false
        }

        return user.isHuman
    }

    func nextAvailableId() -> Int {
        let id = lowestAvailableId
        lowestAvailableId += 1
        return id
    }

    // MARK: - Hashable

    var hashValue: Int {
        return id
    }

    static func ==(lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }
}
