//
//  WWInsomniac.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/14/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWInsomniac: WWCharacter {
	public required init() {
		super.init(name: "Insomniac", instructions: "I am an Insomniac", turnOrder: .last, orderNumber: 10000, selectable: .none, interactionCount: 0, canSelectSelf: false, defaultVisible: [], defaultViewable: .none)
		self.selectionComplete = true
	}
	
	public override func beginNight(with state: WWState) {
		// For some reason necessary
		self.selectionComplete = true
	}
}
