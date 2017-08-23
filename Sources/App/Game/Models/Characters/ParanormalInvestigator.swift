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

    var firstCharacterSelect: Bool = false

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
    override func perform(actions: [Action], with game: Game) {
        guard actions.count > 1 else {
            return
        }

        guard let lastAction = actions.last,
            lastAction.selections.count > 0 else {
                Logger.warning("Invalid Action for PI")
                return
        }

        // We only care if the second card looked at was bad
        let selectedUser = lastAction.selections[0]

        guard let character = game.assignments[selectedUser] else {
            Logger.error("Character assignment does not exist for user")
            return
        }

        if shouldBecome(type(of: character)) {
            // TODO: Finish
//            self.transferedCharacterName = character.name
        }
    }

    override func received(action: Action, user: User, game: Game) -> UpdateType {
        guard action.selections.count > 0 else {
            Logger.warning("Invalid Action for PI")
            return .none
        }

        let selectedUser = action.selections[0]

        if self.firstCharacterSelect {
            self.selectionComplete = true
        }

        if let character = game.assignments[selectedUser] {
            self.firstCharacterSelect = true

            let type = type(of: character)
            user.seenAssignments[selectedUser] = type

            if shouldBecome(type) {
                selectionCount = 0
                selectionComplete = true

                // TODO: Add
//                transferedCharacterName = character.name

                return .full
            }
        } else {
            Logger.warning("Invalid selected character for PI")
        }
        
        return .hidden
    }

    private func shouldBecome(_ type: GameCharacter.Type) -> Bool {
        // TODO: Update to include Tanner
        return Werewolf.self == type || Minion.self == type
    }
}
