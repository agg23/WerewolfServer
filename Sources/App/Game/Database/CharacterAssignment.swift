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

    private let gameAssignmentsId: Int?

    let user: User
    let character: GameCharacter.Type

    init(user: User, character: GameCharacter.Type, parent gameAssignments: GameAssignments) {
        self.user = user
        self.character = character
        self.gameAssignmentsId = gameAssignments.id?.int
    }

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

        self.gameAssignmentsId = try row.get("gameassignment_id")
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("userId", user.identifier)
        try row.set("characterType", character.name)
        try row.set("gameAssignments_id", gameAssignmentsId)

        return row
    }
}

extension CharacterAssignment: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { assignments in
            assignments.id()
            assignments.int("userId")
            assignments.string("characterType")
            assignments.parent(GameAssignments.self, optional: false)
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
