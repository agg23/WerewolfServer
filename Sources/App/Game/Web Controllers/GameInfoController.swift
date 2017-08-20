//
//  GameInfoController.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/18/17.
//
//

import Vapor
import HTTP

class GameInfoController {
    func availableCharacters(_ request: Request) throws -> ResponseRepresentable {
        let gameController = GameController()

        let names = gameController.availableCharacters.map { return $0.name }
        var json = JSON()

        json["characters"] = try JSON(node: names)

        return json
    }
}
