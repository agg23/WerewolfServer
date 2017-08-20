//
//  WWCopycat.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/14/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWCopycat: WWCharacter {
	
	private var inheritedCharacter: WWCharacter?
	
	public required init() {
		super.init(name: "Copycat", instructions: "I am a Copycat", turnOrder: .concurrent, orderNumber: 0, selectable: .nonHumanOnly, interactionCount: 1, canSelectSelf: false, defaultVisible: [], defaultViewable: .none)
		self.selectionComplete = true
	}
	
	public override func perform(action: WWAction, with state: WWState, playerIndex: Int) {
		guard let character = self.inheritedCharacter else {
			print("[WARNING] Invalid inherited character for Copycat")
			return
		}
		
		character.perform(action: action, with: state, playerIndex: playerIndex)
	}
	
	public override func received(action: WWAction, state: WWState) -> Bool {
		let lastActionData = action.actions[action.actions.count - 1]
		
		guard let index = lastActionData.firstSelection else {
			print("[WARNING] Invalid WWActionData for Copycat")
			return false
		}
		
		if let inheritedCharacter = self.inheritedCharacter {
			let received = inheritedCharacter.received(action: action, state: state)
			updateCharacterProperties()
			return received
		} else {
			// Set new character
			if let character = state.assignments[index] {
				self.seenAssignments[index] = character.name
				
				self.transferedCharacterName = character.name
				
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
		
//		self.name = character.name
		self.instructions = character.instructions
		self.turnOrder = character.turnOrder
		self.orderNumber = character.orderNumber
		self.selectable = character.selectable
		self.interactionCount = character.interactionCount
		self.canSelectSelf = character.canSelectSelf
		self.defaultVisible = character.defaultVisible
		self.defaultViewable = character.defaultViewable
		self.selectionComplete = character.selectionComplete
		
		for (index, characterName) in character.seenAssignments {
			self.seenAssignments[index] = characterName
		}
	}
}
