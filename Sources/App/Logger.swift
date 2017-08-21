//
//  Logger.swift
//  WerewolfServer
//
//  Created by Adam Gastineau on 8/20/17.
//
//

import Foundation
import Vapor

class Logger {
    static weak var droplet: Droplet?

    static func info(_ message: String) {
        droplet?.log.info(message)
    }

    static func warning(_ message: String) {
        droplet?.log.warning(message)
    }

    static func error(_ message: String) {
        droplet?.log.error(message)
    }
}
