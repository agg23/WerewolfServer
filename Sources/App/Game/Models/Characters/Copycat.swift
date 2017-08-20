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
        return "Copycat"
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

    override func perform(action: Action, with game: Game, playerIndex: Int) {
        guard let character = self.inheritedCharacter else {
            print("[WARNING] Invalid inherited character for Copycat")
            return
        }

        character.perform(action: action, with: game, playerIndex: playerIndex)
    }

    override func received(action: Action, game: Game) -> Bool {
        guard action.selections.count > 0 else {
            print("[WARNING] Invalid Action for Copycat")
            return false
        }

        let index = action.selections[0]

        if let inheritedCharacter = self.inheritedCharacter {
            let received = inheritedCharacter.received(action: action, game: game)
            updateCharacterProperties()
            return received
        } else {
            // Set new character
            if game.orderedCharacters.count > index {
                let character = game.orderedCharacters[index]
                self.seenAssignments[index] = type(of: character)

                self.inheritedCharacter = character

                updateCharacterProperties()
            } else {
                print("[WARNING] Invalid selected character for Copycat")
            }
        }

        return true
    }

    private func updateCharacterProperties() {
        guard let character = self.inheritedCharacter else {
            print("[WARNING] Invalid inherited character for Copycat. Can't update properties")
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
