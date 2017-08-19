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

        droplet.socket("socket", handler: socketController.socketHandler)
    }
}
