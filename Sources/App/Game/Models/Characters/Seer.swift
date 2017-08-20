//
//  Seer.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

class Seer: GameCharacter {
    override class var name: String {
        return "Seer"
    }

    required init(id: Int) {
        super.init(id: id)

        self.orderType = .concurrent
        self.turnOrder = 10
        self.selectableType = .nonHumanOnly
        self.canSelectSelf = false
        self.defaultVisible = []
        self.defaultVisibleViewableType = .none
        self.selectionCount = 2
    }

    override func perform(action: Action, with game: Game, playerIndex: Int) {
        // Overridden Seer action
    }

    override func received(action: Action, game: Game) -> Bool {
        guard action.selections.count > 1 else {
            Logger.warning("Invalid Action for Seer")
            return false
        }

        let firstIndex = action.selections[0]
        let secondIndex = action.selections[1]

        guard game.users.count > max(firstIndex, secondIndex) else {
            Logger.warning("Invalid selected user(s) for Seer")
            return false
        }

        let firstUser = game.users[firstIndex]
        let secondUser = game.users[secondIndex]

        guard let firstCharacter = game.assignments[firstUser],
            let secondCharacter = game.assignments[secondUser] else {
            Logger.error("Character assignments do not exist for user")
            return false
        }

        self.seenAssignments[firstIndex] = type(of: firstCharacter)
        self.seenAssignments[secondIndex] = type(of: secondCharacter)

        self.selectionComplete = true
        
        return true
    }
}
