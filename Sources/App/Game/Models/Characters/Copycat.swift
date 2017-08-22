//
//  Copycat.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

class Copycat: GameCharacter {
    override class var name: String {
        return "copycat"
    }

    private var inheritedCharacter: GameCharacter?

    required init(id: Int) {
        super.init(id: id)

        self.orderType = .concurrent
        self.turnOrder = 0
        self.selectableType = .nonHumanOnly
        self.canSelectSelf = false
        self.defaultVisible = []
        self.defaultVisibleViewableType = .none
        self.selectionCount = 1
        self.selectionComplete = true
    }

    override func perform(actions: [Action], with game: Game) {
        guard let character = self.inheritedCharacter else {
            Logger.warning("Invalid inherited character for Copycat")
            return
        }

        character.perform(actions: actions, with: game)
    }

    override func received(action: Action, game: Game) -> Bool {
        guard action.selections.count > 0 else {
            Logger.warning("Invalid Action for Copycat")
            return false
        }

        let index = action.selections[0]

        if let inheritedCharacter = self.inheritedCharacter {
            let received = inheritedCharacter.received(action: action, game: game)
            updateCharacterProperties()
            return received
        } else {
            // Set new character
            if game.users.count > index {
                let user = game.users[index]

                guard let character = game.assignments[user] else {
                    Logger.error("Character assignment does not exist for user")
                    return false
                }
                self.seenAssignments[index] = type(of: character)

                self.inheritedCharacter = character

                updateCharacterProperties()
            } else {
                Logger.warning("Invalid selected character for Copycat")
            }
        }

        return true
    }

    private func updateCharacterProperties() {
        guard let character = self.inheritedCharacter else {
            Logger.error("Invalid inherited character for Copycat. Can't update properties")
            return
        }

        self.turnOrder = character.turnOrder
        self.turnOrder = character.turnOrder
        self.selectableType = character.selectableType
        self.selectionCount = character.selectionCount
        self.canSelectSelf = character.canSelectSelf
        self.defaultVisible = character.defaultVisible
        self.defaultVisibleViewableType = character.defaultVisibleViewableType
        self.selectionComplete = character.selectionComplete
        
        for (index, seenCharacter) in character.seenAssignments {
            self.seenAssignments[index] = seenCharacter
        }
    }
}
