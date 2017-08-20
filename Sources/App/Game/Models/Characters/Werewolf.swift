//
//  Werewolf.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

class Werewolf: GameCharacter {
    override class var name: String {
        return "Werewolf"
    }

    required init(id: Int) {
        super.init(id: id)

        self.orderType = .concurrent
        self.turnOrder = 1
        self.selectableType = .nonHumanOnly
        self.canSelectSelf = false
        self.defaultVisible = [Werewolf.self]
        self.defaultVisibleViewableType = .humanOnly
        self.selectionCount = 0
        self.selectionComplete = true
    }

    override func perform(action: Action, with game: Game, playerIndex: Int) {
        // Overridden Werewolf action
    }

    override func beginNight(with game: Game) {
        super.beginNight(with: game)

        var werewolfCount = 0

        for character in game.orderedCharacters where character is Werewolf {
            werewolfCount += 1
        }

        if werewolfCount == 1 {
            self.selectionCount = 1
            self.selectionComplete = false
        } else {
            self.selectionCount = 0
            self.selectionComplete = true
        }
    }

    override func received(action: Action, game: Game) -> Bool {
        guard action.selections.count > 0 else {
            print("[WARNING] Invalid Action for Werewolf")
            return false
        }

        let index = action.selections[0]

        guard game.orderedCharacters.count > index else {
            print("[WARNING] Invalid selected character for Werewolf")
            return false
        }

        let character = game.orderedCharacters[index]
        self.seenAssignments[index] = type(of: character)

        self.selectionComplete = true
        
        return true
    }
}
