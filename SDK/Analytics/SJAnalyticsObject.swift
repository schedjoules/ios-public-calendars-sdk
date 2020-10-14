//
//  SJAnalyticsEvent.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 6/19/20.
//  Copyright © 2020 SchedJoules. All rights reserved.
//

import Foundation

public struct SJAnalyticsCalendar {
    let calendarId: Int
    public let calendarURL: URL?
}

public struct SJAnalyticsObject {
    
    public let calendar: SJAnalyticsCalendar?
    let purchaseMode: SJPurchaseModel?
    let screenName: String?
    
    init(calendar: SJAnalyticsCalendar? = nil, screenName: String? = nil) {
        self.calendar = calendar
        self.screenName = screenName
        
        self.purchaseMode = UserDefaults.standard.sjPurchaseModel
    }
    
    public func asDictionary() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        if let validCalendar = self.calendar {
            dictionary["calendar_id"] = "\(validCalendar.calendarId)" as AnyObject
            
            if let validURL = validCalendar.calendarURL {
                if let webcalURL = validURL.absoluteString.webcalURL() {
                    dictionary["calendar_url"] = webcalURL.absoluteString as AnyObject
                }
            }
        }
        
        if let validPurchaseMode = self.purchaseMode {
            dictionary["purchase_mode"] = validPurchaseMode.trackingValue as AnyObject
        }
        
        if let validScreenName = self.screenName {
            dictionary["screen_name"] = validScreenName as AnyObject
        }
        
        return dictionary
    }
    
}
