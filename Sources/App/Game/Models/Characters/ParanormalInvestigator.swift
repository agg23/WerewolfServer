//
//  ParanormalInvestigator.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

class ParanormalInvestigator: GameCharacter {
    override class var name: String {
        return "pi"
    }

    required init(id: Int) {
        super.init(id: id)

        self.orderType = .concurrent
        self.turnOrder = 18
        self.selectableType = .humanOnly
        self.canSelectSelf = false
        self.defaultVisible = []
        self.defaultVisibleViewableType = .none
        self.selectionCount = 1
        self.selectionComplete = true
    }

    override func beginNight(with game: Game) {
        // For some reason necessary
        self.selectionComplete = true
    }

    // TODO: Finish
//    override func perform(action: Action, with game: Game, playerIndex: Int) {
//        if action.selections.count < 2 {
//            return
//        }
//
//        // We only care if the second card looked at was bad
//        let secondActionData = action.actions[1]
//
//        guard let second = secondActionData.firstSelection else {
//            print("[WARNING] Invalid WWActionData for PI")
//            return
//        }
//
//        guard let character = state.assignments[second] else {
//            print("[WARNING] Invalid selected player for PI")
//            return
//        }
//
//        if shouldBecome(type(of: character)) {
//            self.transferedCharacterName = character.name
//        }
//    }
//
//    public override func received(action: WWAction, state: WWState) -> Bool {
//        let firstActionData = action.actions[0]
//
//        guard let first = firstActionData.firstSelection else {
//            print("[WARNING] Invalid WWActionData for PI")
//            return false
//        }
//
//        if self.firstCharacterSelect {
//            self.selectionComplete = true
//        }
//
//        if let character = state.assignments[first] {
//            self.firstCharacterSelect = true
//
//            let type = type(of: character)
//            self.seenAssignments[first] = character.name
//
//            if shouldBecome(type) {
//                self.interactionCount = 0
//                self.selectionComplete = true
//
//                self.transferedCharacterName = character.name
//                
//                return true
//            }
//        } else {
//            print("[WARNING] Invalid selected character for PI")
//        }
//        
//        return true
//    }

    private func shouldBecome(_ type: GameCharacter.Type) -> Bool {
        // TODO: Update to include Tanner
        return Werewolf.self == type || Minion.self == type
    }
}
