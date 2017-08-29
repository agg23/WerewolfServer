//
//  CharacterAssignment.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/28/17.
//
//

import Foundation
import FluentProvider

final class CharacterAssignment: Model {
    let storage = Storage()

    let user: User
    let character: GameCharacter.Type

    // MARK: - Model

    public required init(row: Row) throws {
        let userId: Int = try row.get("userId")
        let characterType: String = try row.get("characterType")

        guard let user = try User.find(userId),
            let character = GameController.instance.character(for: characterType) else {
            throw DatabaseController.DatabaseError.failedCreation
        }

        self.user = user
        self.character = character
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("userId", user.identifier)
        try row.set("characterType", character.name)

        return row
    }
}

extension CharacterAssignment: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { assignments in
            assignments.id()
            assignments.int("userId")
            assignments.string("characterType")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
