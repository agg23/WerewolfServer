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
        return "witch"
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
        self.selectionComplete = false
    }

    override func perform(actions: [Action], with game: Game) {
        guard let lastAction = actions.last,
            lastAction.selections.count > 1 else {
            Logger.warning("Not two WWActionData for Witch")
            return
        }

        let firstIndex = lastAction.selections[0]
        let secondIndex = lastAction.selections[1]

        // Nonhuman card
        game.swap(firstUser: firstIndex, secondUser: secondIndex)
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
                Logger.warning("Invalid Action for Witch")
                return !temp
            }

            let user = action.selections[0]

            guard let character = game.assignments[user] else {
                Logger.error("Character assignment does not exist for user")
                return false
            }

            seenAssignments[user] = type(of: character)
        } else if !selectionComplete {
            selectionComplete = true
            return true
        }
        
        humanPlayerSelect = true
        
        selectableType = .humanOnly
        
        return !temp
    }
}
