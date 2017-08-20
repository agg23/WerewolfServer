//
//  Witch.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

class Witch: GameCharacter {
    override class var name: String {
        return "Witch"
    }

    private var humanPlayerSelect: Bool

    required init(id: Int) {
        self.humanPlayerSelect = false
        
        super.init(id: id)

        self.orderType = .concurrent
        self.turnOrder = 20
        self.selectableType = .nonHumanOnly
        self.canSelectSelf = false
        self.defaultVisible = []
        self.defaultVisibleViewableType = .none
        self.selectionCount = 1
    }

    override func perform(action: Action, with game: Game, playerIndex: Int) {
        guard action.selections.count > 1 else {
            print("[WARNING] Not two WWActionData for Witch")
            return
        }

        let firstIndex = action.selections[0]
        let secondIndex = action.selections[1]

        // Nonhuman card
        game.swap(firstCharacter: firstIndex, secondCharacter: secondIndex)
    }

    override func beginNight(with game: Game) {
        super.beginNight(with: game)
        humanPlayerSelect = false

        selectableType = .nonHumanOnly
    }

    override func received(action: Action, game: Game) -> Bool {
        let temp = humanPlayerSelect

        if !humanPlayerSelect {
            guard action.selections.count > 0 else {
                print("[WARNING] Invalid Action for Witch")
                return !temp
            }

            let firstIndex = action.selections[0]

            guard game.orderedCharacters.count > firstIndex else {
                print("[WARNING] Invalid selected character for Witch")
                return false
            }

            let character = game.orderedCharacters[firstIndex]
            seenAssignments[firstIndex] = type(of: character)
        } else if !selectionComplete {
            selectionComplete = true
            return true
        }
        
        humanPlayerSelect = true
        
        selectableType = .humanOnly
        
        return !temp
    }
}
