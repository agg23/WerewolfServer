//
//  GameController.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/18/17.
//
//

import Foundation
import WerewolfFramework_Mac

class GameController {
    let availableCharacters: [WWCharacter.Type] = [WWCopycat.self, WWWerewolf.self, WWWerewolf.self, WWMinion.self, WWMason.self, WWMason.self, WWSeer.self, WWPI.self, WWRobber.self, WWWitch.self, WWTroublemaker.self, WWInsomniac.self]

    static let instance = GameController()
}
