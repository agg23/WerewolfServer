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
            print("[WARNING] Invalid Action for Seer")
            return false
        }

        let firstIndex = action.selections[0]
        let secondIndex = action.selections[1]

        guard game.orderedCharacters.count > max(firstIndex, secondIndex) else {
            print("[WARNING] Invalid selected character(s) for Seer")
            return false
        }

        let firstCharacter = game.orderedCharacters[firstIndex]
        let secondCharacter = game.orderedCharacters[secondIndex]

        self.seenAssignments[firstIndex] = type(of: firstCharacter)
        self.seenAssignments[secondIndex] = type(of: secondCharacter)

        self.selectionComplete = true
        
        return true
    }
}
