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
        return "werewolf"
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

    override func perform(actions: [Action], with game: Game) {
        // Overridden Werewolf action
    }

    override func beginNight(with game: Game) {
        super.beginNight(with: game)

        var soloWerewolf = true

        for user in game.users.values {
            if user.isHuman,
                let character = game.assignments[user],
                character != self,
                character is Werewolf {
                soloWerewolf = false
                break
            }
        }

        if soloWerewolf {
            self.selectionCount = 1
            self.selectionComplete = false
        } else {
            self.selectionCount = 0
            self.selectionComplete = true
        }
    }

    override func received(action: Action, user: User, game: Game) -> UpdateType {
        guard action.selections.count > 0 else {
            Logger.warning("Invalid Action for Werewolf")
            return .none
        }

        let selectedUser = action.selections[0]

        guard let character = game.assignments[selectedUser] else {
            Logger.error("Character assignment does not exist for user")
            return .none
        }

        user.seenAssignments[selectedUser] = type(of: character)

        self.selectionComplete = true
        
        return .hidden
    }
}
