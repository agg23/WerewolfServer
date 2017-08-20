//
//  WWGame.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation
// import GameplayKit

public class WWGame {
	public var name: String
	
	public var state: WWState?
	
	public var players: [WWPlayer]
	public var nonHumanPlayers: [WWPlayer]
	
	public var allPlayers: [WWPlayer] {
		return self.players + self.nonHumanPlayers
	}
	
	public var characterTypes: [WWCharacter.Type]
	public var characters: [WWCharacter]
	
	public var nightCanEnd: Bool
	
	private var actions: [WWPlayer: WWAction]
	
	public init(name: String) {
		self.name = name
		
		self.players = [WWPlayer]()
		self.nonHumanPlayers = [WWPlayer]()
		
		self.characterTypes = [WWCharacter.Type]()
		self.characters = [WWCharacter]()
		
		self.nightCanEnd = false
		
		self.actions = [WWPlayer: WWAction]()
	}
	
	public func resetGame() {
		self.nonHumanPlayers = [WWPlayer]()
		
		self.characterTypes = [WWCharacter.Type]()
		self.characters = [WWCharacter]()
		
		self.actions = [WWPlayer: WWAction]()
		self.nightCanEnd = false
	}
	
	public func generateRound() {
		if self.characterTypes.count != self.players.count + self.nonHumanPlayers.count {
			print("[ERROR] Cannot generate round when the number of characters and players does not equal")
		}
		
		// let shuffledCharacterTypes = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self.characterTypes) as! [WWCharacter.Type]
        // TODO: Fix shuffling
        let shuffledCharacterTypes = self.characterTypes
		
		var assignments = [Int: WWCharacter]()
		
		for i in 0 ..< shuffledCharacterTypes.count {
			let characterType = shuffledCharacterTypes[i]
			
			let character = WWCharacter.instantiate(classType: characterType)
			
			assignments[i] = character
			self.characters.append(character)
		}
		
		self.state = WWState(players: self.allPlayers, characters: self.characters, assignments: assignments)
		self.actions = [WWPlayer: WWAction]()
		self.nightCanEnd = false
	}
	
	public func clearState() {
		self.state?.status = .nogame
	}
	
	public func cancelGame() {
		self.state = nil
	}
	
	public func startNight() {
		guard let state = self.state else {
			print("[ERROR] Cannot start night. No state exists")
			return
		}
		
		if state.status == .night {
			print("[WARNING] Attempting to start night when night is current status")
			return
		}
		
		state.status = .night
		
		for character in self.characters {
			character.beginNight(with: state)
		}
		
		let _ = checkNightCanEnd()
	}
	
	public func setDiscussionStatus() {
		state?.status = .discussion
	}
	
	public func checkNightCanEnd() -> Bool {
		guard let state = self.state else {
			print("[ERROR] Cannot check for night end. No state exists")
			return false
		}
		
		var endNight = true
		
		for (playerIndex, loopCharacter) in state.assignments {
			if self.allPlayers[playerIndex].isHumanPlayer {
				endNight = endNight && loopCharacter.selectionComplete
			}
		}
		
		self.nightCanEnd = endNight
		
		return endNight
	}
	
	/**
		Starts the discussion period of the game. Performs all of the queued WWActions and builds an array of players that need updated state after the night has concluded (for example, the insomniac)
	*/
	public func startDiscussion() -> [WWPlayer] {
		guard let state = self.state else {
			print("[ERROR] Cannot start discussion. No state exists")
			return []
		}
		
		setDiscussionStatus()
		
		let playerAssignments = state.playerAssignments
		
		// Build sorted players based on their characters
		let sortedPlayers = playerAssignments.keys.sorted {
			let char1 = playerAssignments[$0]
			let char2 = playerAssignments[$1]
			
			return char1!.orderNumber < char2!.orderNumber
		}
		
		// Perform character actions
		for i in 0 ..< sortedPlayers.count {
			let player = sortedPlayers[i]
			let action = self.actions[player]
			
			if action == nil {
				continue
			}
			
			if action!.actions.count < 1 {
				print("[ERROR] Attempting to process WWAction with no ordering")
				continue
			}
			
			guard let character = playerAssignments[player] else {
				print("[ERROR] WWAction with invalid player")
				continue
			}
			
			character.perform(action: action!, with: state, playerIndex: i)
		}
		
		for i in 0 ..< sortedPlayers.count {
			let player = sortedPlayers[i]
			
			guard let character = playerAssignments[player] else {
				print("[ERROR] WWAction with invalid player")
				continue
			}
			
			character.beginDiscussion(with: state, playerIndex: i)
		}
		
		var array = [WWPlayer]()
		
		for (player, character) in playerAssignments {
			if character.turnOrder == .last {
				array.append(player)
			}
		}
		
		return array
	}
	
	public func endGame() {
		self.state?.status = .nogame
	}
	
	// MARK: - Communication
	
	/**
		Adds the provided WWAction to the list of queued actions. Returns true if the WWCharacter indicated a status update should be sent to the client
	*/
	public func add(action: WWAction, for player: WWPlayer) -> Bool {
		guard let state = self.state else {
			print("[ERROR] Cannot add action. No state exists")
			return false
		}
		
		if action.actions.count < 1 {
			print("[ERROR] Attempting to process WWAction with no action data")
			return false
		}
		
		guard let playerIndex = index(of: player) else {
			print("[ERROR] Invalid player provided on action add")
			return false
		}
		
		let character = state.assignments[playerIndex]
		
		if character != nil && character!.selectionComplete {
			print("[WARNING] Attemped to add WWAction to character that is already complete")
			return false
		}
		
		let shouldUpdate = character?.received(action: action, state: state) ?? false
		
		let previousAction = self.actions[player]
		
		var finalAction: WWAction
		
		if previousAction != nil {
			finalAction = WWAction(actions: previousAction!.actions + action.actions)
		} else {
			finalAction = action
		}
		
		self.actions[player] = finalAction
		
		let _ = checkNightCanEnd()
		
		return shouldUpdate
	}
	
	// MARK: - Player/Character Management
	
	public func registerPlayer(name: String, internalIdentifier: String) -> WWPlayer? {
		let player = WWPlayer(name: name, internalIdentifier: internalIdentifier, human: true)
		
		for player in self.players {
			if player.internalIdentifier == internalIdentifier {
				return player
			}
		}
		
		self.players.append(player)
		
		return player
	}
	
	public func player(with id: String) -> WWPlayer? {
		for i in 0 ..< self.players.count {
			if self.players[i].internalIdentifier == id {
				return self.players[i]
			}
		}
		return nil
	}
	
	public func removePlayer(id: String) {
		for i in 0 ..< self.players.count {
			if self.players[i].internalIdentifier == id {
				self.players.remove(at: i)
				return
			}
		}
	}
	
	private func index(of player: WWPlayer) -> Int? {
		for i in 0 ..< self.players.count {
			if self.players[i] == player {
				return i
			}
		}
		
		return nil
	}
	
	public func registerNonHumanPlayers(count: Int) {
		if self.nonHumanPlayers.count == count {
			return
		}
		
		for i in 0 ..< count {
			let name = String(format: "Center Card %d", i + 1)
			self.nonHumanPlayers.append(WWPlayer(name: name, internalIdentifier: "nonhuman", human: false))
		}
	}
	
	public func register(character: WWCharacter.Type) {
		self.characterTypes.append(character)
	}
	
	public func remove(character: WWCharacter.Type) {
		for i in 0 ..< self.characters.count {
			if self.characterTypes[i] == character {
				self.characters.remove(at: i)
				return
			}
		}
	}
}
