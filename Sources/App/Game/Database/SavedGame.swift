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

    var start: Date?
    var end: Date?

    var winningTeam: String?

    var charactersInPlay: [String] = []

    var startingAssignments: GameAssignments?
    var endingAssignments: GameAssignments?

    let gameHost: User

    var users: Siblings<SavedGame, User, Pivot<SavedGame, User>> {
        return siblings()
    }

    var actions: Children<SavedGame, UserActionCollection> {
        return children()
    }

    init(gameHost: User) {
        self.gameHost = gameHost
    }

    init(start: Date, end: Date, gameHost: User, winningTeam: String?, charactersInPlay: [String], startingAssignments: GameAssignments, endingAssignments: GameAssignments) {
        self.start = start
        self.end = end

        self.gameHost = gameHost

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

        let gameHostId: Identifier = try row.get("gameHostId")

        guard let startingAssignments = try GameAssignments.find(startingAssignmentsId),
            let endingAssignments = try GameAssignments.find(endingAssignmentsId),
            let gameHost = try User.find(gameHostId) else {
                throw DatabaseController.DatabaseError.failedCreation
        }

        self.gameHost = gameHost

        self.startingAssignments = startingAssignments
        self.endingAssignments = endingAssignments
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("startDate", start)
        try row.set("endDate", end)

        try row.set("gameHostId", gameHost.id)

        try row.set("winningTeam", winningTeam)

        try row.set("charactersInPlay", charactersInPlay.joined(separator: ","))

        try row.set("startingAssignmentsId", startingAssignments?.id)
        try row.set("endingAssignmentsId", endingAssignments?.id)

        return row
    }
}

extension SavedGame: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { games in
            games.id()
            games.date("startDate", optional: true)
            games.date("endDate", optional: true)
            games.foreignId(for: User.self, foreignIdKey: "gameHostId")
            games.string("winningTeam", optional: true)
            games.string("charactersInPlay")
            games.foreignId(for: GameAssignments.self, optional: true, foreignIdKey: "startingAssignmentsId")
            games.foreignId(for: GameAssignments.self, optional: true, foreignIdKey: "endingAssignmentsId")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
