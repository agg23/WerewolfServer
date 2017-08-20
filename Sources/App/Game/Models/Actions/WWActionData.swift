//
//  WWActionData.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWActionData {
	/**
		Maps to the index of the first selected player in the WWGame allPlayers array
	*/
	public let firstSelection: Int?
	
	/**
		Maps to the index of the second selected player in the WWGame allPlayers array
	*/
	public let secondSelection: Int?
	
	public init(first: Int?, second: Int?) {
		self.firstSelection = first
		self.secondSelection = second
	}
}
