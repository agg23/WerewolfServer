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
    private var lowestAvailableId: Int = 0

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

    /// - returns: True if game update should be pushed to clients
    func checkGameStatus(_ game: Game) -> Bool {
        // TODO: Handle all states
        var updatedState = false
        switch game.state {
        case .lobby:
            guard !game.userReady.contains(where: { return $0.value == false }) else {
                return false
            }

            Logger.info("Game \(game.id) entering night")

            game.state = .night

            // Create non-player users
            var nonHumanUsers: [User] = []

            for _ in 0 ..< game.nonHumanCount {
                nonHumanUsers.append(userController.createUser(isHuman: false))
            }

            game.users.append(contentsOf: nonHumanUsers)

            // Shuffle characters and instantiate them
            let shuffledCharacters = game.charactersInPlay.shuffled()
            let characters = shuffledCharacters.map({ return $0.init(id: game.nextAvailableId()) })

            // Assign characters to users
            game.mapCharactersToUsers(characters: characters)
            // TODO: Finish night updates
            updateAllCharacters(game)

            updatedState = true
        case .starting:
            game.state = .discussion
            updatedState = checkGameStatus(game)
        case .night:
            break
        case .discussion:
            break
        }

        return updatedState
    }

    func updateGameStatus(_ game: Game) {
        var json = jsonFactory.makeResponse("gameUpdate")

        let userData = game.users.map { return jsonFactory.makeUser($0, using: game) }
        let charactersInPlay = game.charactersInPlay.map { return jsonFactory.makeCharacterType($0) }

        json["players"] = JSON(userData)
        json["inPlay"] = JSON(charactersInPlay)
        json["state"] = JSON(game.state.rawValue)

        sendToUsers(json: json, in: game)
    }

    func updateAllCharacters(_ game: Game) {
        for user in game.users {
            characterUpdate(for: user, in: game)
        }
    }

    func characterUpdate(for user: User, in game: Game) {
        guard let character = game.assignments[user] else {
            Logger.error("Attempted character update for user without assignment")
            return
        }

        var json = JSON()
        json["command"] = "characterUpdate"
        json["character"] = jsonFactory.makeCharacter(character)

        sendTo(user: user, json: json)
    }

    // MARK: - Communication

    func sendToUsers(json: JSON, in game: Game) {
        for user in game.users where user.isHuman {
            sendTo(user: user, json: json)
        }
    }

    func sendTo(user: User, json: JSON) {
        if let socket = userController.userSockets[user] {
            socket.send(json: json)
        } else {
            // TODO: Handle unable to send to user
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
