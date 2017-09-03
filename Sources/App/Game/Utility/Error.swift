//
//  Error.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

extension GameController {
    enum GameError: Error {
        case userAlreadyInGame
        case userNotInGame

        case cannotCreateGame
        case gameIdNotExist
        case gameInvalidPassword

        static let allValues: [GameError] = [.userAlreadyInGame, .userNotInGame, .cannotCreateGame, .gameIdNotExist, .gameInvalidPassword]

        static func message(for error: GameError) -> String {
            switch error {
            case .userAlreadyInGame:
                return "User is already in game"
            case .userNotInGame:
                return "User is not currently in a game"
            case .cannotCreateGame:
                return "Cannot create game"
            case .gameIdNotExist:
                return "Game id doesn't exist"
            case .gameInvalidPassword:
                return "Invalid password"
            }
        }
    }
}
