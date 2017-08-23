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

        var string = try String(contentsOf: url, encoding: .utf8)

        string = string.replacingOccurrences(of: "[38;5;38m", with: "<font color=\"blue\">")
        string = string.replacingOccurrences(of: "[38;5;178m", with: "<font color=\"yellow\">")
        string = string.replacingOccurrences(of: "[38;5;197m", with: "<font color=\"red\">")
        string = string.replacingOccurrences(of: "[0m", with: "</font>")

        string = "<html><body>" + string + "</body></html>"

        var finalString = ""

        string.enumerateLines { (line, _) in
            finalString += "<p>" + line + "</p>"
        }

        return Response(status: Status.init(statusCode: 200), body: finalString)
    }
}
