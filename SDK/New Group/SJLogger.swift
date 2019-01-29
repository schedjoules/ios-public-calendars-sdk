//
//  SJLogger.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 1/29/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation

public func sjPrint(_ items: Any..., separator: String = "\n", terminator: String = "\n") {
    #if DEBUG
    for item in items {
        debugPrint("SchedJoules: \(item)", separator: separator, terminator: terminator)
    }
    #endif
}

