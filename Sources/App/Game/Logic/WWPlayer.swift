//
//  WWPlayer.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWPlayer: Hashable, NSCopying {
	public let isHumanPlayer: Bool
	
	public var name: String
	public var internalIdentifier: String
	
	public init(name: String, internalIdentifier: String, human: Bool) {
		self.isHumanPlayer = human
		
		self.name = name
		self.internalIdentifier = internalIdentifier;
	}
	
	// MARK: - Hashable
	
    public var hashValue: Int {
		return self.internalIdentifier.hashValue
	}
	
	public static func ==(lhs: WWPlayer, rhs: WWPlayer) -> Bool {
		return lhs.name == rhs.name && lhs.internalIdentifier == rhs.internalIdentifier
	}

	// MARK: - NSCopying
	
	public func copy(with zone: NSZone? = nil) -> Any {
		return WWPlayer(name: self.name, internalIdentifier: self.internalIdentifier, human: self.isHumanPlayer)
	}
}
