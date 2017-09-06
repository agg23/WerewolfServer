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
        return "robber"
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
        self.selectionComplete = false
    }

    override func perform(actions: [Action], with game: Game) {
        guard let lastAction = actions.last,
            lastAction.selections.count > 0 else {
            Logger.warning("Invalid Action for Robber")
            return
        }

        let user = lastAction.selections[0]

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

    override func received(action: Action, user: User, game: Game) -> UpdateType {
        guard action.selections.count > 0 else {
            Logger.warning("Invalid WWActionData for Robber")
            return .none
        }

        let selectedUser = action.selections[0]

        guard let character = game.assignments[selectedUser] else {
            Logger.error("Character assignment does not exist for user")
            return .none
        }

        let characterType = type(of: character)

        user.seenAssignments[selectedUser] = characterType

        transferredCharacterType = characterType

        self.selectionComplete = true
        
        return .hidden
    }
}
