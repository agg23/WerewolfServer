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
}
