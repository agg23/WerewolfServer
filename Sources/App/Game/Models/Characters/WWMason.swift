//
//  WWMason.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/14/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWMason: WWCharacter {
	public required init() {
		super.init(name: "Mason", instructions: "I am a Mason", turnOrder: .concurrent, orderNumber: 3, selectable: .none, interactionCount: 0, canSelectSelf: false, defaultVisible: [WWMason.self], defaultViewable: .humanOnly)
		self.selectionComplete = true
	}
	
	public override func beginNight(with state: WWState) {
		// For some reason necessary
		self.selectionComplete = true
	}
	
	public override func perform(action: WWAction, with state: WWState, playerIndex: Int) {
		print("Overridden Mason action!")
	}
}
