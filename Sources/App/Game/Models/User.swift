//
//  User.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/19/17.
//
//

import Vapor
import FluentProvider

public final class User: Model, Hashable {
    public let storage = Storage()

    var identifier: Int {
        return id?.int ?? -1
    }

    let username: String

    /// Stores the password hashed
    var passwordHash: String

    var nickname: String?

    let isHuman: Bool

    /// Mapping from user to character type seen
    var seenAssignments: [User: GameCharacter.Type] = [:]

    weak var game: Game?

    init(username: String, passwordHash: String, nickname: String?) {
        self.username = username
        self.passwordHash = passwordHash
        self.nickname = nickname

        self.isHuman = true
    }

    init(nonHumanNumber: Int) {
        self.username = "Nonhuman \(nonHumanNumber)"
        self.passwordHash = ""
        self.nickname = "Center card \(nonHumanNumber)"

        self.isHuman = false
    }

    // MARK: - Model

    public required init(row: Row) throws {
        self.username = try row.get("username")
        self.passwordHash = try row.get("password")

        self.nickname = try row.get("nickname")

        self.isHuman = try row.get("isHuman")
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", id)
        try row.set("username", username)
        try row.set("password", passwordHash)

        try row.set("nickname", nickname)

        try row.set("isHuman", isHuman)

        return row
    }

    // MARK: - Hashable

    public var hashValue: Int {
        return identifier
    }

    public static func ==(lhs: User, rhs: User) -> Bool {
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
    public static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.string("username")
            users.string("password")
            users.string("nickname", optional: true)
            users.bool("isHuman")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
