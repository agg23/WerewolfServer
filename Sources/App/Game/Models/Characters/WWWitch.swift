//
//  WWWitch.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWWitch: WWCharacter {
	private var humanPlayerSelect: Bool
	
	public required init() {
		self.humanPlayerSelect = false
		
		super.init(name: "Witch", instructions: "I am a Witch", turnOrder: .concurrent, orderNumber: 20, selectable: .nonHumanOnly, interactionCount: 1, canSelectSelf: true, defaultVisible: [], defaultViewable: .none)
	}
	
	public override func perform(action: WWAction, with state: WWState, playerIndex: Int) {
		print("Overridden Witch action!")
		
		if action.actions.count < 2 {
			print("[WARNING] Not two WWActionData for Witch")
			return
		}
		
		let firstActionData = action.actions[action.actions.count - 2]
		
		guard let secondActionData = action.lastAction else {
			print("[WARNING] Missing WWActionData for Witch")
			return
		}
		
		guard let first = firstActionData.firstSelection, let second = secondActionData.firstSelection else {
			print("[WARNING] Invalid WWActionData for Witch")
			return
		}
		
		// Nonhuman card
		state.swap(first: first, second: second)
	}
	
	public override func beginNight(with state: WWState) {
		super.beginNight(with: state)
		self.humanPlayerSelect = false
		
		self.selectable = .nonHumanOnly
	}
	
	public override func received(action: WWAction, state: WWState) -> Bool {
		let temp = self.humanPlayerSelect
		
		if !self.humanPlayerSelect {
			// At least 1 data is guaranteed
			let firstActionData = action.actions[0]
			
			guard let first = firstActionData.firstSelection else {
				print("[WARNING] Invalid WWActionData for Witch")
				return !temp
			}
			
			if let character = state.assignments[first] {
				self.seenAssignments[first] = character.name
			} else {
				print("[WARNING] Invalid selected character for Witch")
			}
		} else if !self.selectionComplete {
			self.selectionComplete = true
			return true
		}
		
		self.humanPlayerSelect = true
		
		self.selectable = .humanOnly
		
		return !temp
	}
}
