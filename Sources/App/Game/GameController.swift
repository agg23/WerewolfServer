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

    func nextAvailableId() -> Int {
        let id = lowestAvailableId
        lowestAvailableId += 1
        return id
    }
}
