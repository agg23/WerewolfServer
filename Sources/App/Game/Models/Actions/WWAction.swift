//
//  WWAction.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWAction {
	/**
		WWActionData representing the selected players
	*/
	public let actions: [WWActionData]
	
	public var lastAction: WWActionData? {
		if self.actions.count < 1 {
			return nil
		}
		
		return self.actions[self.actions.count - 1]
	}
	
	public init(actions: [WWActionData]) {
		self.actions = actions
	}
}
