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
