//
//  User.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/19/17.
//
//

import Vapor
import FluentProvider

class User: Hashable {
    let id: Int
    var nickname: String

    let isHuman: Bool

    /// Mapping from user to character type seen
    var seenAssignments: [User: GameCharacter.Type] = [:]

    weak var game: Game?

    init(id: Int, isHuman: Bool) {
        self.id = id
        self.isHuman = isHuman

        self.nickname = isHuman ? "User \(id)" : "Nonhuman \(id)"
    }

    // MARK: - Hashable

    var hashValue: Int {
        return id
    }

    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    static func isViewable(type: GameCharacter.ViewableType, user: User) -> Bool {
        switch type {
        case .all:
            return true
        case .none:
            return false
        case .humanOnly:
            return user.isHuman
        case .nonHumanOnly:
            return !user.isHuman
        }
    }
}
