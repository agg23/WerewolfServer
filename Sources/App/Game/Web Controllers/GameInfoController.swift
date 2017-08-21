//
//  GameInfoController.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/18/17.
//
//

import Foundation
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

    func viewLog(_ request: Request) throws -> ResponseRepresentable {
        let path = FileManager.default.currentDirectoryPath + "/log.log"
        let url = URL(fileURLWithPath: path)
        return try String.init(contentsOf: url)
    }
}
