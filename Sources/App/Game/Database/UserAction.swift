//
//  UserAction.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/29/17.
//
//

import Foundation
import FluentProvider

final class UserAction: Model {
    let storage = Storage()

    let type: Action.SelectionType

    let rotation: Action.Rotation?

    var selections: Siblings<UserAction, User, Pivot<UserAction, User>> {
        return siblings()
    }

    init(type: Action.SelectionType, rotation: Action.Rotation) {
        self.type = type
        self.rotation = rotation
    }

    // MARK: - Model

    public required init(row: Row) throws {
        let type: String = try row.get("type")
        let rotation: String? = try row.get("rotation")

        self.type = Action.SelectionType(rawValue: type) ?? .single

        if let rotation = rotation {
            self.rotation = Action.Rotation(rawValue: rotation)
        } else {
            self.rotation = nil
        }
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("type", type.rawValue)
        try row.set("rotation", rotation?.rawValue)

        return row
    }
}

extension UserAction: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { action in
            action.id()
            action.string("type")
            action.string("rotation")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}