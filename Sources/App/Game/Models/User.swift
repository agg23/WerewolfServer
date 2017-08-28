//
//  User.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/19/17.
//
//

import Vapor
import FluentProvider

final class User: Model, Hashable {
    let storage = Storage()

    var identifier: Int {
        return id?.int ?? 0
    }

    let username: String
    var password: String

    var nickname: String

    let isHuman: Bool

    /// Mapping from user to character type seen
    var seenAssignments: [User: GameCharacter.Type] = [:]

    weak var game: Game?

    init(id: Int, isHuman: Bool) {
        // TODO: Finish
        self.username = ""
        self.password = ""

        self.isHuman = isHuman

        self.nickname = isHuman ? "User \(id)" : "Nonhuman \(id)"
    }

    // MARK: - Model

    required init(row: Row) throws {
        self.username = try row.get("username")
        self.password = try row.get("password")

        self.nickname = try row.get("nickname")

        self.isHuman = true
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", id)
        try row.set("username", username)
        try row.set("password", password)

        try row.set("nickname", nickname)

        return row
    }

    // MARK: - Hashable

    var hashValue: Int {
        return identifier
    }

    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.hashValue == rhs.hashValue
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

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.string("username")
            users.string("password")
            users.string("nickname")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
