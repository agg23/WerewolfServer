//
//  GameAssignments.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/28/17.
//
//

import Foundation
import FluentProvider

public final class GameAssignments: Model {
    public let storage = Storage()

    var assignments: Children<GameAssignments, CharacterAssignment> {
        return children()
    }

    init() {
        
    }

    // MARK: - Model

    public required init(row: Row) throws {

    }

    public func makeRow() throws -> Row {
        return Row()
    }
}

extension GameAssignments: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { action in
            action.id()
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
