//
//  GeneralExtensions.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation

func cs_arc4random_uniform(_ upperBound: UInt32) -> UInt32 {
    #if os(Linux)
        // TODO: Fix
        return UInt32(random()) % upperBound
    #else
        return arc4random_uniform(upperBound)
    #endif
}

// From https://stackoverflow.com/a/24029847
extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }

        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(cs_arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
