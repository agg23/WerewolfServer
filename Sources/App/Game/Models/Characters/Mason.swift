//
//  Mason.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

class Mason: GameCharacter {
    override class var name: String {
        return "mason"
    }

    required init(id: Int) {
        super.init(id: id)

        self.orderType = .concurrent
        self.turnOrder = 3
        self.selectableType = .none
        self.canSelectSelf = false
        self.defaultVisible = [Mason.self]
        self.defaultVisibleViewableType = .humanOnly
        self.selectionCount = 0
        self.selectionComplete = true
    }

    override func beginNight(with game: Game) {
        // For some reason necessary
        self.selectionComplete = true
    }

    override func perform(action: Action, with game: Game, playerIndex: Int) {
        // Overridden Mason action
    }
}
