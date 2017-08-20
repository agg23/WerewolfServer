//
//  WWState.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWState {
	
	public enum GameStatus: String {
		case starting = "starting"
		case night = "night"
		case discussion = "discussion"
		case nogame = "nogame"
	}
	
	public var players: [WWPlayer]
	public var characters: [WWCharacter]
	public var assignments: [Int: WWCharacter]
	
	public var status: GameStatus
	
	init(players: [WWPlayer], characters: [WWCharacter], assignments: [Int: WWCharacter]) {
		self.players = players
		self.characters = characters
		self.assignments = assignments
		
		self.status = .nogame
	}
	
	public var playerAssignments: [WWPlayer: WWCharacter] {
		var playerAssignments = [WWPlayer: WWCharacter]()
		
		for i in 0 ..< self.players.count {
			let player = self.players[i]
			playerAssignments[player] = self.assignments[i]
		}
		
		return playerAssignments
	}
	
	public func player(at index: Int) -> WWPlayer? {
		if index >= self.players.count {
			return nil
		}
		
		return self.players[index]
	}
	
	func swap(first firstPlayerIndex: Int, second secondPlayerIndex: Int) {
		let temp = self.assignments[firstPlayerIndex]
		let temp2 = self.assignments[secondPlayerIndex]
		
		temp?.transferedCharacterName = nil
		temp2?.transferedCharacterName = nil
		
		self.assignments[firstPlayerIndex] = temp2
		self.assignments[secondPlayerIndex] = temp
	}
}
