//
//  GameCharacter.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

class GameCharacter: Equatable {
    enum OrderType {
        case concurrent
        case last
        case inactive
    }

    enum ViewableType {
        case all
        case humanOnly
        case nonHumanOnly
        case none
    }

    class var name: String {
        return "Default Character"
    }

    var id: Int

    var orderType: OrderType = .concurrent

    var selectableType: ViewableType = .none

    var turnOrder: Int?

    var canSelectSelf: Bool = false

    var defaultVisible: [GameCharacter.Type] = []

    var defaultVisibleViewableType: ViewableType = .none

    var selectionCount: Int = 0

    var selectionComplete: Bool = true

    /// Mapping from character index to character type seen
    var seenAssignments: [Int: GameCharacter.Type] = [:]

    required init(id: Int) {
        self.id = id
    }

    /// Interprets the provided Action (typically created from the GUI) and mutates the Game state
    func perform(action: Action, with game: Game, playerIndex: Int) {
        print("[WARNING] Default action performed. Nothing was changed")
    }

    // Performs any changes dictated by the current Game before entering night, such as a solo Werewolf adding a selectable
    func beginNight(with game: Game) {
        selectionComplete = false
        seenAssignments = [:]
    }

    /// Performs any changes dictated by the current WWState before entering discussion, such as Insomniac updating their roll
    public func beginDiscussion(with game: Game, playerIndex: Int) {

    }

    /// Performs any necessary changes based on the provided Action. Returns true if updated state needs to be sent to the owning client
    public func received(action: Action, game: Game) -> Bool {
        selectionComplete = true
        
        return true
    }

    static func ==(lhs: GameCharacter, rhs: GameCharacter) -> Bool {
        return lhs.id == rhs.id
    }
}
