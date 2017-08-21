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
    }

    override func perform(action: Action, with game: Game, playerIndex: Int) {
        guard action.selections.count > 1 else {
            Logger.warning("Not two WWActionData for Witch")
            return
        }

        let firstIndex = action.selections[0]
        let secondIndex = action.selections[1]

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

            let index = action.selections[0]

            guard game.users.count > index else {
                Logger.warning("Invalid selected user for Witch")
                return false
            }

            let user = game.users[index]

            guard let character = game.assignments[user] else {
                Logger.error("Character assignment does not exist for user")
                return false
            }

            seenAssignments[index] = type(of: character)
        } else if !selectionComplete {
            selectionComplete = true
            return true
        }
        
        humanPlayerSelect = true
        
        selectableType = .humanOnly
        
        return !temp
    }
}
