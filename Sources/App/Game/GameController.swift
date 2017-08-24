//
//  GameController.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/18/17.
//
//

import Foundation

class GameController {
    // TODO: Add in ParanormalInvestigator.self
    let availableCharacters: [GameCharacter.Type] = [Copycat.self, Werewolf.self, Werewolf.self, Minion.self, Mason.self, Mason.self, Seer.self, Robber.self, Witch.self, Troublemaker.self, Insomniac.self]

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

    /// - returns: True if game status update should be pushed to clients
    func checkGameStatus(_ game: Game) -> Bool {
        let startingGameState = game.state

        switch game.state {
        case .lobby:
            guard !game.userReady.contains(where: { return $0.value == false }) else {
                return false
            }

            Logger.info("Game \(game.id) entering night")

            game.state = .night

            // Create non-player users
            for _ in 0 ..< game.nonHumanCount {
                game.registerUser(userController.createUser(isHuman: false))
            }

            _ = game.users.map({ $0.value.seenAssignments = [:] })

            // Shuffle characters and instantiate them
            let shuffledCharacters = game.charactersInPlay.shuffled()
            let characters = shuffledCharacters.map({ return $0.init(id: game.nextAvailableId()) })

            // Assign characters to users
            game.mapCharactersToUsers(characters: characters)

            // Update defaultViewable
            for assignment in game.assignments {
                for innerAssignment in game.assignments where assignment.key != innerAssignment.key {
                    if checkDefaultViewable(innerAssignment.value.defaultVisible, character: assignment.value, on: assignment.key, with: innerAssignment.value.defaultVisibleViewableType) {
                        innerAssignment.key.seenAssignments[assignment.key] = type(of: assignment.value)
                    }
                }
            }

            let assignments = game.assignments.map({ (value) -> JSON in return jsonFactory.makeCharacterAssignment(for: value.key, with: value.value) })
            do {
                let bytes = try JSON(assignments).makeBytes()
                Logger.info(bytes.makeString())
            } catch {
                // Ignore failure
            }

            updateAllCharacters(game, type: .full)

            // To allow instant transition to discussion
            // TODO: Fix
            _ = checkGameStatus(game)
        case .starting:
            game.state = .discussion
            _ = checkGameStatus(game)
        case .night:
            guard !game.assignments.filter({ $0.key.isHuman }).contains(where: { !$0.value.selectionComplete }) else {
                return false
            }

            // Mark all users as unready, for exiting discussion
            for user in game.users.values {
                game.unreadyUser(user)
            }

            Logger.info("Game \(game.id) entering discussion")

            game.state = .discussion

            // Perform character actions
            let sortedAssignments = game.assignments.sorted(by: { (first, second) -> Bool in
                return first.value.turnOrder < second.value.turnOrder
            })

            for assignment in sortedAssignments {
                guard let actions = game.actions[assignment.key] else {
                    continue
                }

                assignment.value.perform(actions: actions, with: game)
            }

            for assignment in game.assignments {
                // TODO: Remove?
                assignment.value.beginDiscussion(with: game)
            }

            let assignmentsNeedingUpdates = game.assignments.filter({ return $0.value.orderType == .last })

            for assignment in assignmentsNeedingUpdates {
                characterUpdate(for: assignment.key, in: game)
            }
        case .discussion:
            guard !game.userReady.contains(where: { return $0.value == false }) else {
                return false
            }

            Logger.info("Game \(game.id) entering lobby")

            sendFinalGameResults(game)

            game.state = .lobby
        }

        return game.state != startingGameState
    }

    func sendFinalGameResults(_ game: Game) {
        var json = jsonFactory.makeResponse("gameResults")

        let assignments = game.assignments.map({ (value) -> JSON in return jsonFactory.makeCharacterAssignment(for: value.key, with: value.value) })
        json["assignments"] = JSON(assignments)

        sendToUsers(json: json, in: game)
    }

    func updateGameStatus(_ game: Game) {
        var json = jsonFactory.makeResponse("gameUpdate")

        let userData = game.users.map { return jsonFactory.makeUser($0.value, using: game) }
        let charactersInPlay = game.charactersInPlay.map { return jsonFactory.makeCharacterType($0) }

        json["players"] = JSON(userData)
        json["inPlay"] = JSON(charactersInPlay)
        json["state"] = JSON(game.state.rawValue)

        sendToUsers(json: json, in: game)
    }

    func updateAllCharacters(_ game: Game, type: GameCharacter.UpdateType) {
        for user in game.users.values {
            if type == .full {
                characterUpdate(for: user, in: game)
            } else {
                hiddenCharacterUpdate(for: user, in: game)
            }
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
        json["seenAssignments"] = jsonFactory.makeSeenAssignments(user)

        sendTo(user: user, json: json)
    }

    func hiddenCharacterUpdate(for user: User, in game: Game) {
        guard let startingCharacter = game.startingAssignments[user] else {
            Logger.error("Attempted character update for user without assignment")
            return
        }

        var json = JSON()
        json["command"] = "characterUpdate"
        json["character"] = jsonFactory.makeCharacter(startingCharacter)
        json["seenAssignments"] = jsonFactory.makeSeenAssignments(user)

        sendTo(user: user, json: json)
    }

    // MARK: - User Actions

    func user(_ user: User, selectedType type: Action.SelectionType, selections: [User]?, rotation: Action.Rotation?) throws {
        guard let game = user.game, let character = game.assignments[user] else {
            throw GameController.GameError.userNotInGame
        }

        guard !character.selectionComplete else {
            Logger.warning("Received action for user \(user.id) when selection complete")
            return
        }

        switch type {
        case .single:
            guard let selections = selections, selections.count > 0 else {
                throw SocketController.ParseError.malformedData("selections")
            }
        case .double:
            guard let selections = selections, selections.count > 1 else {
                throw SocketController.ParseError.malformedData("selections")
            }
        case .rotate:
            guard rotation != nil else {
                throw SocketController.ParseError.malformedData("rotation")
            }
        }

        let action = Action(type: type, selections: selections ?? [], rotation: rotation)

        game.addAction(action, for: user)

        let characterNeedsUpdate = character.received(action: action, user: user, game: game)

        let shouldUpdateGameStatus = checkGameStatus(game)

        if shouldUpdateGameStatus {
            updateGameStatus(game)
        }

        if characterNeedsUpdate == .full {
            characterUpdate(for: user, in: game)
        } else if characterNeedsUpdate == .hidden {
            hiddenCharacterUpdate(for: user, in: game)
        }

        // Update all defaultviewables
        // Should be fine, since only selections are happening at this point. No changes are actually made, so no data will be leaked
        for assignment in game.assignments where assignment.value != character {
            let characterType = type(of: character)
            if checkDefaultViewable(assignment.value.defaultVisible, character: character, on: user, with: assignment.value.defaultVisibleViewableType) {
                assignment.key.seenAssignments[user] = characterType
                hiddenCharacterUpdate(for: assignment.key, in: game)
            }
        }
    }

    func checkDefaultViewable(_ defaultVisible: [GameCharacter.Type], character: GameCharacter, on user: User, with viewableType: GameCharacter.ViewableType) -> Bool {
        return User.isViewable(type: viewableType, user: user) && defaultVisible.contains(where: { $0 == type(of: character) })
    }

    // MARK: - Communication

    func sendToUsers(json: JSON, in game: Game) {
        for user in game.users.values where user.isHuman {
            sendTo(user: user, json: json)
        }
    }

    func sendTo(user: User, json: JSON) {
        if let socket = userController.userSockets[user] {
            socket.send(json: json, user: user)
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
