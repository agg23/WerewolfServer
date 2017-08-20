//
//  Robber.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

class Robber: GameCharacter {
    override class var name: String {
        return "Robber"
    }

    required init(id: Int) {
        super.init(id: id)

        self.orderType = .concurrent
        self.turnOrder = 19
        self.selectableType = .humanOnly
        self.canSelectSelf = false
        self.defaultVisible = []
        self.defaultVisibleViewableType = .none
        self.selectionCount = 1
        self.selectionComplete = true
    }

    override func perform(action: Action, with game: Game, playerIndex: Int) {
        guard action.selections.count > 0 else {
            Logger.warning("Invalid Action for Robber")
            return
        }

        let index = action.selections[0]

        guard game.users.count > index else {
            Logger.warning("Invalid selected user for Robber")
            return
        }

        let user = game.users[index]

        guard let newCharacter = game.assignments[user] else {
            Logger.error("Character assignment does not exist for user")
            return
        }

        guard let selfUser = game.user(for: self) else {
            Logger.error("Rogger does not exist in game")
            return
        }

        game.assignments[selfUser] = newCharacter

        game.assignments[user] = self
        // TODO: Just call swap?
    }

    override func received(action: Action, game: Game) -> Bool {
        guard action.selections.count > 0 else {
            Logger.warning("Invalid WWActionData for Robber")
            return false
        }

        let index = action.selections[0]

        guard game.users.count > index else {
            Logger.warning("Invalid selected user for Robber")
            return false
        }

        let user = game.users[index]

        guard let character = game.assignments[user] else {
            Logger.error("Character assignment does not exist for user")
            return false
        }

        self.seenAssignments[index] = type(of: character)

        self.selectionComplete = true
        
        return true
    }
}
