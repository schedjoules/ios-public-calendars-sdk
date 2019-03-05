//
//  SJSecureStorageQueryable.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 3/4/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation

public protocol SJSecureStorageQueryable {
    var query: [String: Any] { get }
}

public struct SJApiSecureStorageQueryable {
    let service = "CalendarStore"
    let accessGroup = "SchedJoules"
}

extension SJApiSecureStorageQueryable: SJSecureStorageQueryable {
    
    public var query: [String : Any] {
        var query: [String: Any] = [:]
        query[String(kSecClass)] = kSecClassGenericPassword
        query[String(kSecAttrService)] = service
        // Access group if target environment is not simulator
        #if !targetEnvironment(simulator)
        if let accessGroup = accessGroup {
            query[String(kSecAttrAccessGroup)] = accessGroup
        }
        #endif
        return query
    }
}
