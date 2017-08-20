//
//  JSONFactory.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation
import JSON
import WerewolfFramework_Mac

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

        let assignment: JSON
        if let character = game.assignments[user] {
            assignment = makeCharacter(character)
        } else {
            assignment = JSON.null
        }

        json["assignment"] = assignment

        return json
    }

    func makeCharacterType(_ characterType: WWCharacter.Type) -> JSON {
        var json = JSON()

        json["name"] = JSON(WWCharacter.name(type: characterType))
        // TODO: Add id (other info?)

        return json
    }

    func makeCharacter(_ character: WWCharacter) -> JSON {
        // TODO: Fix
        return JSON.null
    }
}
