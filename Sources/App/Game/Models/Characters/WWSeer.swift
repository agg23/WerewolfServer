//
//  WWSeer.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWSeer: WWCharacter {
	public required init() {
		super.init(name: "Seer", instructions: "I am a Seer", turnOrder: .concurrent, orderNumber: 10, selectable: .nonHumanOnly, interactionCount: 2, canSelectSelf: false, defaultVisible: [], defaultViewable: .none)
	}
	
	public override func perform(action: WWAction, with state: WWState, playerIndex: Int) {
		print("Overridden Seer action!")
	}
	
	public override func received(action: WWAction, state: WWState) -> Bool {
		let firstActionData = action.actions[0]
		
		guard let first = firstActionData.firstSelection, let second = firstActionData.secondSelection else {
			print("[WARNING] Invalid WWActionData for Seer")
			return false
		}
		
		if let firstCharacter = state.assignments[first], let secondCharacter = state.assignments[second] {
			self.seenAssignments[first] = firstCharacter.name
			self.seenAssignments[second] = secondCharacter.name
		} else {
			print("[WARNING] Invalid selected character(s) for Seer")
		}
		
		self.selectionComplete = true
		
		return true
	}
}
