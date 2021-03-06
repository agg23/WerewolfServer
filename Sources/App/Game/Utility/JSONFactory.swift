//
//  JSONFactory.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation
import JSON

class JSONFactory {
    func makeResponse(_ response: String) -> JSON {
        var json = JSON()
        json["command"] = JSON(response)
        return json
    }

    func makeUser(_ user: User, using game: Game) -> JSON {
        var json = JSON()

        json["id"] = JSON(user.identifier)
        json["nickname"] = JSON(user.nickname ?? "")

        if let ready = game.userReady[user] {
            json["ready"] = JSON(ready)
        } else if user.isHuman {
            Logger.warning("Ready state for user \(user.identifier) could not be determined")
        }

        json["isHuman"] = JSON(user.isHuman)

        return json
    }

    func makeCharacterType(_ characterType: GameCharacter.Type) -> JSON {
        var json = JSON()

        json["name"] = JSON(characterType.name)
        // TODO: Add id (other info?)

        return json
    }

    func makeCharacter(_ character: GameCharacter) -> JSON {
        var json = JSON()

        json["name"] = JSON(type(of: character).name)

        if let transferredCharacterType = character.transferredCharacterType {
            json["lastKnownName"] = JSON(transferredCharacterType.name)
        }

        var allowedActions = JSON()

        if character.selectableType != .none {
            allowedActions["selectionCount"] = JSON(character.selectionComplete ? 0 : character.selectionCount)
            allowedActions["canSelectSelf"] = JSON(character.canSelectSelf)
        }

        allowedActions["selectionType"] = JSON(character.selectableType.rawValue)

        json["allowedActions"] = allowedActions

        return json
    }

    func makeSeenAssignments(_ user: User) -> JSON {
        let assignments = user.seenAssignments.map { (value) -> JSON in
            var assignmentJson = JSON()
            assignmentJson["id"] = JSON(value.key.identifier)
            assignmentJson["character"] = JSON(value.value.name)
            return assignmentJson
        }

        return JSON(assignments)
    }

    func makeCharacterAssignment(for user: User, with character: GameCharacter) -> JSON {
        var json = JSON()
        
        json["id"] = JSON(user.identifier)
        json["character"] = JSON(type(of: character).name)

        return json
    }

    func makeGame(_ game: Game) -> JSON {
        var json = JSON()

        json["id"] = JSON(game.id)

        if let name = game.name {
            json["name"] = JSON(name)
        } else {
            json["name"] = JSON.null
        }

        if let nickname = game.host.nickname {
            json["hostNickname"] = JSON(nickname)
        } else {
            json["hostNickname"] = JSON.null
        }

        json["userCount"] = JSON(game.users.count)

        json["passwordProtected"] = JSON(game.password != nil)

        json["state"] = JSON(game.state.rawValue)

        json["charactersInPlay"] = JSON(game.charactersInPlay.map({ $0.name }).joined(separator: ","))

        return json
    }
}
