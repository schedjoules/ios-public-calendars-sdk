//
//  SJAnalyticsEvent.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 6/19/20.
//  Copyright © 2020 SchedJoules. All rights reserved.
//

import Foundation

public struct SJAnalyticsCalendar {
    let calendarId: String
    let calendarURL: String
}

public struct SJAnalyticsObject {
    
    let calendar: SJAnalyticsCalendar?
    let purchaseMode: SJPurchaseModel?
    let isFree: Bool
    let screenName: String?
    
    var dictionary: [String: AnyObject] {
        get {
            var dictionary: [String: AnyObject] = [:]
            if let validCalendar = self.calendar {
                dictionary["calendar_id"] = validCalendar.calendarId as AnyObject
                dictionary["calendar_url"] = validCalendar.calendarURL as AnyObject
            }
            
            if let validPurchaseMode = self.purchaseMode {
                dictionary["purchase_mode"] = validPurchaseMode.trackingValue as AnyObject
            }
            
            dictionary["is_free"] = self.isFree as AnyObject
            
            if let validScreenName = self.screenName {
                dictionary["screen_name"] = validScreenName as AnyObject
            }
            
            return dictionary
        }
    }
    
    init(calendar: SJAnalyticsCalendar? = nil, screenName: String? = nil) {
        self.calendar = calendar
        self.screenName = screenName
        
        self.purchaseMode = UserDefaults.standard.sjPurchaseModel
        
        if StoreManager.shared.isSubscriptionValid == true {
            isFree = false
        } else {
            let freeSubscriptionRecord = FreeSubscriptionRecord()
            if freeSubscriptionRecord.canGetFreeCalendar() == true {
                isFree = true
            } else {
                isFree = false
            }
        }
        
    }
    
}
