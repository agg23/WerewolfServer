//
//  Troublemaker.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

class Troublemaker: GameCharacter {
    override class var name: String {
        return "Troublemaker"
    }

    required init(id: Int) {
        super.init(id: id)

        self.orderType = .concurrent
        self.turnOrder = 100
        self.selectableType = .humanOnly
        self.canSelectSelf = false
        self.defaultVisible = []
        self.defaultVisibleViewableType = .none
        self.selectionCount = 2
    }

    override func perform(action: Action, with game: Game, playerIndex: Int) {
        guard action.selections.count > 1 else {
            print("[WARNING] Invalid WWActionData for Troublemaker")
            return
        }

        let firstIndex = action.selections[0]
        let secondIndex = action.selections[1]
        
        game.swap(firstCharacter: firstIndex, secondCharacter: secondIndex)
    }
}
