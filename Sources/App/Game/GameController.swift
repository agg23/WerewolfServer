//
//  GameController.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/18/17.
//
//

import Foundation
import WerewolfFramework_Mac

class GameController {
    let availableCharacters: [WWCharacter.Type] = [WWCopycat.self, WWWerewolf.self, WWWerewolf.self, WWMinion.self, WWMason.self, WWMason.self, WWSeer.self, WWPI.self, WWRobber.self, WWWitch.self, WWTroublemaker.self, WWInsomniac.self]

    static let instance = GameController()

    private(set) var games: Set<Game> = []
    var lowestAvailableId: Int = 0

    func createGame() -> Game {
        return Game(id: nextAvailableId())
    }

    func registerGame(_ game: Game) {
        games.insert(game)

        print("Registered game \(game.id)")
    }

    func game(with id: Int) throws -> Game {
        guard let game = games.first(where: { $0.id == id }) else {
            throw GameError.gameIdNotExist
        }

        return game
    }

    func joinGame(_ game: Game, password: String?, user: User) throws {
        guard user.game == nil else {
            throw GameError.userAlreadyInGame
        }

        if let password = password {
            guard game.password == password else {
                throw GameError.gameInvalidPassword
            }
        }

        game.registerUser(user)

        // TODO: Send current game status
    }

    func leaveGame(user: User) throws {
        guard let game = user.game else {
            throw GameController.GameError.userNotInGame
        }

        user.game = nil
        game.removeUser(user)

        // TODO: Send current game status
    }

    func nextAvailableId() -> Int {
        let id = lowestAvailableId
        lowestAvailableId += 1
        return id
    }
}
