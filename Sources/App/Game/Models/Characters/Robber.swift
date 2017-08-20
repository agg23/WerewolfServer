//
//  Robber.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

class Robber: GameCharacter {
    override class var name: String {
        return "Robber"
    }

    required init(id: Int) {
        super.init(id: id)

        self.orderType = .concurrent
        self.turnOrder = 19
        self.selectableType = .humanOnly
        self.canSelectSelf = false
        self.defaultVisible = []
        self.defaultVisibleViewableType = .none
        self.selectionCount = 1
        self.selectionComplete = true
    }

    override func perform(action: Action, with game: Game, playerIndex: Int) {
        guard action.selections.count > 0 else {
            print("[WARNING] Invalid Action for Robber")
            return
        }

        let index = action.selections[0]

        guard game.orderedCharacters.count > index else {
            print("[WARNING] Invalid player for Robber")
            return
        }

        let newCharacter = game.orderedCharacters[index]

        guard let selfIndex = game.orderedCharacters.index(where: { return $0 == self }) else {
            print("[ERROR] Robber does not exist in game")
            return
        }

        game.orderedCharacters[selfIndex] = newCharacter

        game.orderedCharacters[index] = self
        // TODO: Update assignments
        // TODO: Just call swap?
    }

    override func received(action: Action, game: Game) -> Bool {
        guard action.selections.count > 0 else {
            print("[WARNING] Invalid WWActionData for Robber")
            return false
        }

        let index = action.selections[0]

        guard game.orderedCharacters.count > index else {
            print("[WARNING] Invalid selected character for Robber")
            return false
        }

        let character = game.orderedCharacters[index]
        self.seenAssignments[index] = type(of: character)

        self.selectionComplete = true
        
        return true
    }
}
