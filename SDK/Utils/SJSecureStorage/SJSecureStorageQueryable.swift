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


public struct SJSubscriptionSecureStorageQueryable {
    let service = "CalendarStore-SubscriptionId"
    let accessGroup = "SchedJoules"
}

extension SJSubscriptionSecureStorageQueryable: SJSecureStorageQueryable {
    public var query: [String : Any] {
        var query: [String: Any] = [:]
        query[String(kSecClass)] = kSecClassGenericPassword
        query[String(kSecAttrService)] = service
        query[String(kSecAttrAccessGroup)] = accessGroup
        return query
    }
}
