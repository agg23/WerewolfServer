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
        json["nickname"] = JSON(user.nickname)

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

        if character.selectableType != .none {
            allowedActions["selectionCount"] = JSON(character.selectionComplete ? 0 : character.selectionCount)
        }

        allowedActions["selectionType"] = JSON(character.selectableType.rawValue)

        json["allowedActions"] = allowedActions

        return json
    }

    func makeSeenAssignments(_ user: User) -> JSON {
        let assignments = user.seenAssignments.map { (value) -> JSON in
            var assignmentJson = JSON()
            assignmentJson["id"] = JSON(value.key.id)
            assignmentJson["character"] = JSON(value.value.name)
            return assignmentJson
        }

        return JSON(assignments)
    }

    func makeCharacterAssignment(for user: User, with character: GameCharacter) -> JSON {
        var json = JSON()
        
        json["id"] = JSON(user.id)
        json["character"] = JSON(type(of: character).name)

        return json
    }
}
