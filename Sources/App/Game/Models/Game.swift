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

    var state: State

    var charactersInPlay: [GameCharacter.Type] = []

    var users: Set<User> = []
    var userIndexes: Set<Int> = []
    var orderedCharacters: [GameCharacter] = []

    var assignments: [User: GameCharacter] = [:]

    var userReady: [User: Bool] = [:]

    init(id: Int) {
        self.id = id

        self.state = .lobby
    }

    func registerUser(_ user: User) {
        users.insert(user)

        userReady[user] = false

        user.game = self
    }

    func removeUser(_ user: User) {
        users.remove(user)

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

    func swap(firstCharacter firstIndex: Int, secondCharacter secondIndex: Int) {
        let temp = self.orderedCharacters[firstIndex]
        let temp2 = self.orderedCharacters[secondIndex]

        self.orderedCharacters[firstIndex] = temp2
        self.orderedCharacters[secondIndex] = temp

        // TODO: Update assignments
    }

    func isPlayer(with character: GameCharacter) -> Bool {
        guard let index = orderedCharacters.index(where: { return $0 == character }) else {
            Logger.error("Character does not exist in this game")
            return false
        }

        return isPlayer(at: index)
    }

    func isPlayer(at index: Int) -> Bool {
        return userIndexes.contains(index)
    }

    // MARK: - Hashable

    var hashValue: Int {
        return id
    }

    static func ==(lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }
}
