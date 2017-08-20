//
//  Action.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

class Action {
    enum SelectionType: String {
        case single = "singleSelection"
        case double = "doubleSelection"
        case rotate = "rotateSelection"
    }

    enum Rotation: String {
        case left = "left"
        case right = "right"
    }

    var type: SelectionType

    /// The indexes selected by the action
    var selections: [Int] = []

    var rotation: Rotation?

    init(type: SelectionType, selections: [Int], rotation: Rotation?) {
        self.type = type
        self.selections = selections
        self.rotation = rotation
    }
}
