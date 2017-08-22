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

    var users: [Int: User] = [:]

    var userReady: [User: Bool] = [:]

    var assignments: [User: GameCharacter] = [:]
    var startingAssignments: [User: GameCharacter] = [:]
    var actions: [User: [Action]] = [:]

    private var lowestAvailableId: Int = 0

    init(id: Int) {
        self.id = id

        self.state = .lobby
    }

    func registerUser(_ user: User) {
        users[user.id] = user

        if user.isHuman {
            userReady[user] = false
        }

        user.game = self
    }

    func removeUser(_ user: User) {
        users.removeValue(forKey: user.id)

        userReady.removeValue(forKey: user)

        user.game = nil
    }

    func readyUser(_ user: User) {
        userReady[user] = true
    }

    func unreadyUser(_ user: User) {
        userReady[user] = false
    }

    func addAction(_ action: Action, for user: User) {
        var userActions = actions[user]

        if userActions == nil {
            userActions = []
        }

        userActions?.append(action)

        actions[user] = userActions
    }

    // MARK: - Utility

    func swap(firstUser: User, secondUser: User) {
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

        let usersArray = Array(users.values)

        for (i, user) in zip(usersArray.indices, usersArray) {
            let character = characters[i]
            assignments[user] = character
        }

        startingAssignments = assignments
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
