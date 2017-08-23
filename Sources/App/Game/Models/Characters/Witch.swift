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

    private var humanPlayerSelected: Bool

    required init(id: Int) {
        self.humanPlayerSelected = false
        
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
            Logger.warning("Not two Actions for Witch")
            return
        }

        let firstUser = lastAction.selections[0]
        let secondUser = lastAction.selections[1]

        // Nonhuman card
        game.swap(firstUser: firstUser, secondUser: secondUser)
    }

    override func beginNight(with game: Game) {
        super.beginNight(with: game)
        humanPlayerSelected = false

        selectableType = .nonHumanOnly
    }

    override func received(action: Action, user: User, game: Game) -> UpdateType {
        let temp = humanPlayerSelected

        if !humanPlayerSelected {
            guard action.selections.count > 0 else {
                Logger.warning("Invalid Action for Witch")
                // TODO: What?
                return .hidden
            }

            let selectedUser = action.selections[0]

            guard let character = game.assignments[selectedUser] else {
                Logger.error("Character assignment does not exist for user")
                return .none
            }

            user.seenAssignments[selectedUser] = type(of: character)
        } else if !selectionComplete {
            selectionComplete = true
            return .hidden
        }
        
        humanPlayerSelected = true
        
        selectableType = .humanOnly
        
        return !temp ? .hidden : .none
    }
}
