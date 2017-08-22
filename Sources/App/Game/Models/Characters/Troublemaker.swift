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
        return "troublemaker"
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

    override func perform(actions: [Action], with game: Game) {
        guard let lastAction = actions.last,
            lastAction.selections.count > 1 else {
            Logger.warning("Invalid Action for Troublemaker")
            return
        }

        let firstIndex = lastAction.selections[0]
        let secondIndex = lastAction.selections[1]
        
        game.swap(firstUser: firstIndex, secondUser: secondIndex)
    }
}
