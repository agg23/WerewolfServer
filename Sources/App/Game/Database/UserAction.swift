//
//  UserAction.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/29/17.
//
//

import Foundation
import FluentProvider

public final class UserAction: Model {
    public let storage = Storage()

    private let userActionCollection: Int?

    let type: Action.SelectionType

    let rotation: Action.Rotation?

    /// Userd to store the order in which a user performed actions
    let order: Int

    var selections: Siblings<UserAction, User, Pivot<UserAction, User>> {
        return siblings()
    }

    init(type: Action.SelectionType, rotation: Action.Rotation?, order: Int, actionCollection: UserActionCollection) {
        self.type = type
        self.rotation = rotation
        self.order = order

        self.userActionCollection = actionCollection.id?.int
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

        self.order = try row.get("order")

        self.userActionCollection = try row.get("user_action_collection_id")
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("type", type.rawValue)
        try row.set("rotation", rotation?.rawValue)
        try row.set("order", order)

        try row.set("user_action_collection_id", userActionCollection)

        return row
    }
}

extension UserAction: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { action in
            action.id()
            action.string("type")
            action.string("rotation", optional: true)
            action.int("order")
            action.parent(UserActionCollection.self)
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
