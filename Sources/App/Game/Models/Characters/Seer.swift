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
        return "seer"
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
        self.selectionComplete = false
    }

    override func perform(actions: [Action], with game: Game) {
        // Overridden Seer action
    }

    override func received(action: Action, game: Game) -> UpdateType {
        guard action.selections.count > 1 else {
            Logger.warning("Invalid Action for Seer")
            return .none
        }

        let firstUser = action.selections[0]
        let secondUser = action.selections[1]

        guard let firstCharacter = game.assignments[firstUser],
            let secondCharacter = game.assignments[secondUser] else {
            Logger.error("Character assignments do not exist for user")
            return .none
        }

        self.seenAssignments[firstUser] = type(of: firstCharacter)
        self.seenAssignments[secondUser] = type(of: secondCharacter)

        self.selectionComplete = true
        
        return .hidden
    }
}
