//
//  AnalyticsEvent.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 2019. 01. 01..
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation

struct AnalyticsEvent {
    
    var type: String
    var details: [String: AnyObject]?
    var date: Date
    
    init(type: String, details: [String: AnyObject]?) {
        self.type = type
        self.details = details
        self.date = Date()
    }
    
}
