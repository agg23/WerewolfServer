//
//  UserActionCollection.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/29/17.
//
//

import Foundation
import FluentProvider

public final class UserActionCollection: Model {
    public let storage = Storage()

    private let savedGameId: Int?

    let user: User

    var actions: Children<UserActionCollection, UserAction> {
        return children()
    }

    init(user: User, savedGame: SavedGame) {
        self.user = user

        self.savedGameId = savedGame.id?.int
    }

    // MARK: - Model

    public required init(row: Row) throws {
        let userId: Int = try row.get("userId")

        guard let user = try User.find(userId) else {
            throw DatabaseController.DatabaseError.failedCreation
        }

        self.user = user

        self.savedGameId = try row.get("saved_game_id")
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("userId", user.identifier)

        try row.set("saved_game_id", savedGameId)

        return row
    }
}

extension UserActionCollection: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { action in
            action.id()
            action.int("userId")
            action.parent(SavedGame.self)
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
