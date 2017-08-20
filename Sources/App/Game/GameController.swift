//
//  GameController.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/18/17.
//
//

import Foundation

class GameController {
    let availableCharacters: [GameCharacter.Type] = [Copycat.self, Werewolf.self, Werewolf.self, Minion.self, Mason.self, Mason.self, Seer.self, ParanormalInvestigator.self, Robber.self, Witch.self, Troublemaker.self, Insomniac.self]

    static let instance = GameController()
    let userController = UserController.instance

    let jsonFactory = JSONFactory()

    private(set) var games: Set<Game> = []
    var lowestAvailableId: Int = 0

    func createGame() -> Game {
        return Game(id: nextAvailableId())
    }

    func registerGame(_ game: Game) {
        games.insert(game)

        Logger.info("Registered game \(game.id)")
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

        updateGameStatus(game)
    }

    func leaveGame(user: User) throws {
        guard let game = user.game else {
            throw GameController.GameError.userNotInGame
        }

        user.game = nil
        game.removeUser(user)

        updateGameStatus(game)
    }

    // MARK: - Status

    func updateGameStatus(_ game: Game) {
        var json = jsonFactory.makeResponse("gameUpdate")

        let userData = game.users.map { return jsonFactory.makeUser($0, using: game) }
        let charactersInPlay = game.charactersInPlay.map { return jsonFactory.makeCharacterType($0) }
//        let status = game.internalGame.state?.status ?? .nogame

        json["players"] = JSON(userData)
        json["inPlay"] = JSON(charactersInPlay)
//        json["state"] = JSON(status.rawValue)

        sendToUsers(json: json, in: game)
    }

    // MARK: - Communication

    func sendToUsers(json: JSON, in game: Game) {
        for user in game.users {
            if let socket = userController.userSockets[user] {
                socket.send(json: json)
            } else {
                // TODO: Handle unable to send to user
            }
        }
    }

    // MARK: - Utility

    func nextAvailableId() -> Int {
        let id = lowestAvailableId
        lowestAvailableId += 1
        return id
    }

    func character(for name: String) -> GameCharacter.Type? {
        return availableCharacters.first(where: { return $0.name == name })
    }
}
