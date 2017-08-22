//
//  Insomniac.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

class Insomniac: GameCharacter {
    override class var name: String {
        return "insomniac"
    }

    required init(id: Int) {
        super.init(id: id)

        self.orderType = .last
        self.turnOrder = 10000
        self.selectableType = .none
        self.canSelectSelf = false
        self.defaultVisible = []
        self.defaultVisibleViewableType = .none
        self.selectionCount = 0
        self.selectionComplete = true
    }

    public override func beginNight(with game: Game) {
        // For some reason necessary
        self.selectionComplete = true
    }

    override func perform(actions: [Action], with game: Game) {
        // Overridden Insomniac action
    }
}
