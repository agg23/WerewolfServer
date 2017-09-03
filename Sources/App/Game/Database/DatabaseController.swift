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

    func createNewGame(host: User) -> Int? {
        do {
            let savedGame = SavedGame(gameHost: host)
            try savedGame.save()
            return savedGame.id?.int
        } catch {
            return nil
        }
    }

    func saveCompletedGame(_ game: Game) {
        Logger.info("Saving game \(game.id)")

        guard let start = game.startDate else {
            Logger.warning("Cannot save game that never started")
            return
        }

        var previouslySavedGame: SavedGame?

        do {
            previouslySavedGame = try SavedGame.find(game.id)
        } catch {
            // Do nothing
        }

        let charactersInPlay = game.charactersInPlay.map({ return $0.name })

        if let savedGame = previouslySavedGame {
            // Update existing record
            do {
                let startingAssignments = try makeGameAssignments(assignments: game.startingAssignments)
                let endingAssignments = try makeGameAssignments(assignments: game.assignments)

                savedGame.start = start
                savedGame.end = Date()

                // TODO: Add
                savedGame.winningTeam = nil

                savedGame.charactersInPlay = charactersInPlay
                savedGame.startingAssignments = startingAssignments
                savedGame.endingAssignments = endingAssignments

                try saveActions(in: game, savedGame: savedGame)
            } catch {
                Logger.error("Could not save game \(game.id) with error \(error)")
            }
        } else {
            do {
                let startingAssignments = try makeGameAssignments(assignments: game.startingAssignments)
                let endingAssignments = try makeGameAssignments(assignments: game.assignments)

                let savedGame = SavedGame(start: start, end: Date(), gameHost: game.host, winningTeam: nil, charactersInPlay: charactersInPlay, startingAssignments: startingAssignments, endingAssignments: endingAssignments)
                try savedGame.save()

                try saveActions(in: game, savedGame: savedGame)
            } catch {
                Logger.error("Could not save game \(game.id) with error \(error)")
            }
        }

        Logger.info("Saving game \(game.id) complete")
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

    func makeActionCollection(user: User, actions: [Action], in savedGame: SavedGame) throws -> UserActionCollection {
        let actionCollection = UserActionCollection(user: user, savedGame: savedGame)
        try actionCollection.save()

        for (i, action) in zip(actions.indices, actions) {
            let userAction = UserAction(type: action.type, rotation: action.rotation, order: i, actionCollection: actionCollection)
            try userAction.save()

            _ = try action.selections.map({ try userAction.selections.add($0) })
        }

        return actionCollection
    }

    func saveActions(in game: Game, savedGame: SavedGame) throws {
        for user in game.actions.keys {
            guard let actions = game.actions[user] else {
                Logger.error("User key somehow does not exist")
                continue
            }

            _ = try makeActionCollection(user: user, actions: actions, in: savedGame)
        }
    }
}
