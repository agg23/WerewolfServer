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

        json["id"] = JSON(user.id)
        if let nickname = user.nickname {
            json["nickname"] = JSON(nickname)
        }

        if let ready = game.userReady[user] {
            json["ready"] = JSON(ready)
        } else if user.isHuman {
            Logger.warning("Ready state for user \(user.id) could not be determined")
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

        json["id"] = JSON(character.id)
        json["name"] = JSON(type(of: character).name)

        var allowedActions = JSON()

        allowedActions["selectableType"] = JSON(character.selectableType.rawValue)

        if character.selectableType != .none {
            allowedActions["selectionCount"] = JSON(character.selectionComplete ? 0 : character.selectionCount)
        }

        allowedActions["selectionType"] = JSON(character.selectableType.rawValue)

        json["allowedActions"] = allowedActions

        return json
    }

    func makeSeenAssignments(_ character: GameCharacter) -> JSON {
        let assignments = character.seenAssignments.map { (value) -> JSON in
            var assignmentJson = JSON()
            assignmentJson["id"] = JSON(value.key.id)
            assignmentJson["character"] = JSON(value.value.name)
            return assignmentJson
        }

        return JSON(assignments)
    }
}
