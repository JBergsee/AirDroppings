//
//  LogCategory+URLScheme.swift
//  AirDroppings
//
//  Created by Johan Bergsee on 2024-01-23.
//  
//

import Logging

public extension LogCategory {
    ///Logs issues and events during parsing
    static let urlScheme = LogCategory(rawValue: "URL reception")!
}
