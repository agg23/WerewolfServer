//
//  WWPI.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/11/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWPI: WWCharacter {
	
	public var firstCharacterSelect: Bool
	
	public required init() {
		self.firstCharacterSelect = false
		
		super.init(name: "PI", instructions: "I am a Paranormal Investigator", turnOrder: .concurrent, orderNumber: 18, selectable: .humanOnly, interactionCount: 1, canSelectSelf: false, defaultVisible: [], defaultViewable: .none)
		self.selectionComplete = true
	}
	
	public override func perform(action: WWAction, with state: WWState, playerIndex: Int) {
		if action.actions.count < 2 {
			return
		}
		
		// We only care if the second card looked at was bad
		let secondActionData = action.actions[1]
		
		guard let second = secondActionData.firstSelection else {
			print("[WARNING] Invalid WWActionData for PI")
			return
		}
		
		guard let character = state.assignments[second] else {
			print("[WARNING] Invalid selected player for PI")
			return
		}
		
		if shouldBecome(type(of: character)) {
			self.transferedCharacterName = character.name
		}
	}
	
	public override func received(action: WWAction, state: WWState) -> Bool {
		let firstActionData = action.actions[0]
		
		guard let first = firstActionData.firstSelection else {
			print("[WARNING] Invalid WWActionData for PI")
			return false
		}
		
		if self.firstCharacterSelect {
			self.selectionComplete = true
		}
		
		if let character = state.assignments[first] {
			self.firstCharacterSelect = true
			
			let type = type(of: character)
			self.seenAssignments[first] = character.name
			
			if shouldBecome(type) {
				self.interactionCount = 0
				self.selectionComplete = true
				
				self.transferedCharacterName = character.name
				
				return true
			}
		} else {
			print("[WARNING] Invalid selected character for PI")
		}
		
		return true
	}
	
	private func shouldBecome(_ type: WWCharacter.Type) -> Bool {
		// TODO: Update to include Tanner
		return WWWerewolf.self == type || WWMinion.self == type
	}
}
