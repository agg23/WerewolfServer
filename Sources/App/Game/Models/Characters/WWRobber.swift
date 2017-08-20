//
//  WWRobber.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/11/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWRobber: WWCharacter {
	public required init() {
		super.init(name: "Robber", instructions: "I am a Robber", turnOrder: .concurrent, orderNumber: 19, selectable: .humanOnly, interactionCount: 1, canSelectSelf: false, defaultVisible: [], defaultViewable: .none)
		self.selectionComplete = true
	}
	
	public override func perform(action: WWAction, with state: WWState, playerIndex: Int) {
		let firstActionData = action.actions[0]
		
		guard let first = firstActionData.firstSelection else {
			print("[WARNING] Invalid WWActionData for Robber")
			return
		}

		guard let newCharacter = state.assignments[first] else {
			print("[WARNING] Invalid player for Robber")
			return
		}
		
		for (playerIndex, character) in state.assignments {
			if character == self {
				state.assignments[playerIndex] = newCharacter
				break
			}
		}
		
		state.assignments[first] = self
	}
	
	public override func received(action: WWAction, state: WWState) -> Bool {
		let firstActionData = action.actions[0]
		
		guard let first = firstActionData.firstSelection else {
			print("[WARNING] Invalid WWActionData for Robber")
			return false
		}
		
		if let character = state.assignments[first] {
			self.seenAssignments[first] = character.name
		} else {
			print("[WARNING] Invalid selected character for Robber")
		}
		
		self.selectionComplete = true
		
		return true
	}
}
