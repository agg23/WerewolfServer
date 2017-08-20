//
//  WWMinion.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWMinion: WWCharacter {
	public required init() {
		super.init(name: "Minion", instructions: "I am a Minion", turnOrder: .concurrent, orderNumber: 2, selectable: .none, interactionCount: 0, canSelectSelf: false, defaultVisible: [WWWerewolf.self], defaultViewable: .humanOnly)
		self.selectionComplete = true
	}
	
	public override func beginNight(with state: WWState) {
		// For some reason necessary
		self.selectionComplete = true
	}
	
	public override func perform(action: WWAction, with state: WWState, playerIndex: Int) {
		print("Overridden Minion action!")
	}
}
