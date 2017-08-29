//
//  GameAssignments.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/28/17.
//
//

import Foundation
import FluentProvider

final class GameAssignments: Model {
    let storage = Storage()

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
