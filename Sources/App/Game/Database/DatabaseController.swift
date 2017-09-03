//
//  DatabaseController.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/28/17.
//
//

import Foundation

class DatabaseController {
    enum DatabaseError: Error {
        case failedCreation
    }

    func saveCompletedGame(_ game: Game) {
        guard let start = game.startDate else {
            Logger.warning("Cannot save game that never started")
            return
        }

        do {
            let startingAssignments = try makeGameAssignments(assignments: game.startingAssignments)
            let endingAssignments = try makeGameAssignments(assignments: game.assignments)

            let savedGame = SavedGame(start: start, end: Date(), winningTeam: nil, charactersInPlay: game.charactersInPlay.map({ return $0.name }), startingAssignments: startingAssignments, endingAssignments: endingAssignments)
            try savedGame.save()
        } catch {
            Logger.error("Could not save game \(game.id) with error \(error)")
        }
    }

    func makeGameAssignments(assignments: [User: GameCharacter]) throws -> GameAssignments {
        let gameAssignment = GameAssignments()
        try gameAssignment.save()
        for (user, character) in assignments {
            let characterAssignment = CharacterAssignment(user: user, character: type(of: character), parent: gameAssignment)
            try characterAssignment.save()
        }

        return gameAssignment
    }
}
