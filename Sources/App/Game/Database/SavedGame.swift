//
//  SavedGame.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/28/17.
//
//

import Foundation
import FluentProvider

public final class SavedGame: Model {
    public let storage = Storage()

    let start: Date
    let end: Date

    let winningTeam: String?

    let charactersInPlay: [String]

    let startingAssignments: GameAssignments
    let endingAssignments: GameAssignments

    var users: Siblings<SavedGame, User, Pivot<SavedGame, User>> {
        return siblings()
    }

    var actions: Children<SavedGame, UserActionCollection> {
        return children()
    }

    init(start: Date, end: Date, winningTeam: String?, charactersInPlay: [String], startingAssignments: GameAssignments, endingAssignments: GameAssignments) {
        self.start = start
        self.end = end

        self.winningTeam = winningTeam

        self.charactersInPlay = charactersInPlay

        self.startingAssignments = startingAssignments
        self.endingAssignments = endingAssignments
    }

    // MARK: - Model

    public required init(row: Row) throws {
        self.start = try row.get("startDate")
        self.end = try row.get("endDate")

        self.winningTeam = try row.get("winningTeam")

        let inPlay: String = try row.get("charactersInPlay")
        self.charactersInPlay = inPlay.components(separatedBy: ",")

        let startingAssignmentsId: Identifier = try row.get("startingAssignmentsId")
        let endingAssignmentsId: Identifier = try row.get("endingAssignmentsId")

        guard let startingAssignments = try GameAssignments.find(startingAssignmentsId),
            let endingAssignments = try GameAssignments.find(endingAssignmentsId) else {
                throw DatabaseController.DatabaseError.failedCreation
        }

        self.startingAssignments = startingAssignments
        self.endingAssignments = endingAssignments
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("startDate", start)
        try row.set("endDate", end)

        try row.set("winningTeam", winningTeam)

        try row.set("charactersInPlay", charactersInPlay.reduce("", { (result, string) -> String in
            return "\(result),\(string)"
        }))

        try row.set("startingAssignmentsId", startingAssignments.id)
        try row.set("endingAssignmentsId", endingAssignments.id)

        return row
    }
}

extension SavedGame: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { games in
            games.id()
            games.date("startDate")
            games.date("endDate")
            games.string("winningTeam", optional: true)
            games.string("charactersInPlay")
            games.string("startingAssignmentsId")
            games.string("endingAssignmentsId")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
