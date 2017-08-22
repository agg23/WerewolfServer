//
//  Minion.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

class Minion: GameCharacter {
    override class var name: String {
        return "minion"
    }

    required init(id: Int) {
        super.init(id: id)

        self.orderType = .concurrent
        self.turnOrder = 2
        self.selectableType = .none
        self.canSelectSelf = false
        self.defaultVisible = [Werewolf.self]
        self.defaultVisibleViewableType = .humanOnly
        self.selectionCount = 0
        self.selectionComplete = true
    }

    override func beginNight(with game: Game) {
        // For some reason necessary
        self.selectionComplete = true
    }

    override func perform(actions: [Action], with game: Game) {
        // Overridden Minion action
    }
}
