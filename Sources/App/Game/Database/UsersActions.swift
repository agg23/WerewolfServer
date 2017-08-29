//
//  UsersActions.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/29/17.
//
//

import Foundation
import FluentProvider

final class UsersActions: Model {
    let storage = Storage()

    let user: User

    var actions: Children<UsersActions, UserAction> {
        return children()
    }

    init(user: User) {
        self.user = user
    }

    // MARK: - Model

    public required init(row: Row) throws {
        let userId: Int = try row.get("userId")

        guard let user = try User.find(userId) else {
            throw DatabaseController.DatabaseError.failedCreation
        }

        self.user = user
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("userId", user.identifier)

        return row
    }
}

extension UsersActions: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { action in
            action.id()
            action.int("userId")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
