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
    let availableCharacters: [GameCharacter.Type] = [Copycat.self, Werewolf.self, Werewolf.self, Minion.self, Mason.self, Mason.self, Seer.self, ParanormalInvestigator.self, Robber.self, Witch.self, Troublemaker.self, Insomniac.self]

    static let instance = GameController()
    let userController = UserController.instance
    let databaseController = DatabaseController()

    let jsonFactory = JSONFactory()

    private(set) var games: Set<Game> = []

    private var nonHumanUsers: [User] = []

    init() {
        // If first 10 users are not nonhuman, add them
        for i in 1..<11 {
            var user: User? = nil
            do {
                user = try User.find(i)
            } catch {
                fatalError("User database error \(error)")
            }

            guard let foundUser = user else {
                // User does not exist, create it
                let newUser = User(nonHumanNumber: i)
                do {
                    try newUser.save()
                } catch {
                    // Cannot save new user, fail
                    fatalError("Cannot create non human user")
                }

                nonHumanUsers.append(newUser)

                continue
            }

            guard !foundUser.isHuman else {
                // Cannot be human. Must fail
                fatalError("Human user already exists with non human id")
            }

            nonHumanUsers.append(foundUser)
        }
    }

    func createGame(host: User) throws -> Game {
        let id = databaseController.createNewGame(host: host)

        guard let gameId = id else {
            throw GameError.cannotCreateGame
        }

        return Game(id: gameId, host: host)
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
            throw GameError.userNotInGame
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

            guard game.nonHumanCount <= nonHumanUsers.count else {
                Logger.warning("Attempting to start game with more non human users than are available")
                return false
            }

            Logger.info("Game \(game.id) entering night")

            game.state = .night

            // Create non-player users
            for i in 0 ..< game.nonHumanCount {
                game.registerUser(nonHumanUsers[i])
            }

            _ = game.users.map({ $0.value.seenAssignments = [:] })

            // Shuffle characters and instantiate them
            let shuffledCharacters = game.charactersInPlay.shuffled()
            let characters = shuffledCharacters.map({ return $0.init(id: game.nextAvailableId()) })

            // Assign characters to users
            game.mapCharactersToUsers(characters: characters)

            _ = game.assignments.map({ $0.value.beginNight(with: game) })

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

            game.startDate = Date()

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

            let assignmentsNeedingUpdates = game.startingAssignments.filter({ return $0.value.orderType == .last })

            for assignment in assignmentsNeedingUpdates {
                characterUpdate(for: assignment.key, in: game)
            }
        case .discussion:
            guard !game.userReady.contains(where: { return $0.value == false }) else {
                return false
            }

            // Mark all users as unready, for starting the next game
            for user in game.users.values {
                game.unreadyUser(user)
            }

            Logger.info("Game \(game.id) entering lobby")

            databaseController.saveCompletedGame(game)

            sendFinalGameResults(game)

            game.state = .lobby

            // Update game id

            let id = databaseController.createNewGame(host: game.host)

            guard let gameId = id else {
                Logger.error("Cannot transfer game to new id")
                return true
            }

            game.id = gameId
            game.assignments = [:]
            game.startingAssignments = [:]
            game.actions = [:]
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

        json["id"] = JSON(game.id)
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
            Logger.warning("Received action for user \(user.identifier) when selection complete")
            return
        }

        var userSelections: [User] = []

        switch type {
        case .single:
            guard let fullSelections = selections, fullSelections.count > 0 else {
                throw SocketController.ParseError.malformedData("selections")
            }

            userSelections = Array(fullSelections[0..<1])
        case .double:
            guard let fullSelections = selections, fullSelections.count > 1 else {
                throw SocketController.ParseError.malformedData("selections")
            }

            userSelections = Array(fullSelections[0..<2])
        case .rotate:
            guard rotation != nil else {
                throw SocketController.ParseError.malformedData("rotation")
            }
        }

        let action = Action(type: type, selections: userSelections, rotation: rotation)

        game.addAction(action, for: user)

        let characterNeedsUpdate = character.received(action: action, user: user, game: game)

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

        let shouldUpdateGameStatus = checkGameStatus(game)

        if shouldUpdateGameStatus {
            updateGameStatus(game)
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

    func character(for name: String) -> GameCharacter.Type? {
        return availableCharacters.first(where: { return $0.name == name })
    }
}
