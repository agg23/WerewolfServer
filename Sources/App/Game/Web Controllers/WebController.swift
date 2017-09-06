//
//  WebController.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/19/17.
//
//

import Foundation
import Vapor

class WebController {
    static let instance = WebController()

    let socketController = SocketController()

    let gameInfoController = GameInfoController()

    func registerRoutes(to droplet: Droplet) {
        droplet.get("availableCharacters", handler: gameInfoController.availableCharacters)
        droplet.get("availableGames", handler: gameInfoController.availableGames)
        droplet.get("log", handler: gameInfoController.viewLog)

        socketController.version = droplet.config["server", "version"]?.string ?? "0.1"
        droplet.socket("socket", handler: socketController.socketHandler)
    }
}
