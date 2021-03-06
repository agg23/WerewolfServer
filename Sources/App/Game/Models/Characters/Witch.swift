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
    private var selectedCharacterType: GameCharacter.Type?
    private var selectedNonhumanUser: User?

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
        // TODO: Fix dying on this.
        guard actions.count > 1,
            let lastAction = actions.last else {
            Logger.warning("Not two Actions for Witch")
            return
        }

        let secondLastAction = actions[actions.count - 2]

        guard lastAction.selections.count > 0,
            secondLastAction.selections.count > 0 else {
            Logger.warning("Last two Actions for Witch have insufficient counts")
            return
        }

        let firstUser = secondLastAction.selections[0]
        
        // Nonhuman card
        let secondUser = lastAction.selections[0]

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
            selectedNonhumanUser = selectedUser

            guard let character = game.assignments[selectedUser] else {
                Logger.error("Character assignment does not exist for user")
                return .none
            }

            let type = type(of: character)

            user.seenAssignments[selectedUser] = type

            selectedCharacterType = type

            canSelectSelf = true
        } else if !selectionComplete {
            // Human user was just selected
            guard action.selections.count > 0 else {
                Logger.warning("Invalid Action for Witch")
                return .hidden
            }

            let selectedUser = action.selections[0]

            if selectedUser == user,
                let selectedCharacterType = selectedCharacterType {
                transferredCharacterType = selectedCharacterType

                // Update seen assignment for nonhuman user
                if let selectedNonhumanUser = selectedNonhumanUser {
                    user.seenAssignments[selectedNonhumanUser] = type(of: self)
                }
            } else if let selectedCharacterType = selectedCharacterType {
                // Add seen assignment for the user we gave the selected type to
                user.seenAssignments[selectedUser] = selectedCharacterType
                
                // Update seen assignment for nonhuman user
                if let selectedNonhumanUser = selectedNonhumanUser {
                    user.seenAssignments[selectedNonhumanUser] = nil
                }
            }

            selectionComplete = true
            canSelectSelf = false
            return .hidden
        }
        
        humanPlayerSelected = true
        
        selectableType = .humanOnly
        
        return !temp ? .hidden : .none
    }
}
