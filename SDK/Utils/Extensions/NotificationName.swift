//
//  NotificationName.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 10/1/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation

struct SJAnalyticsEvent {
    struct SJCalendar {
        let calendarId: String
        let calendarURL: String
    }
    
    let calendar: SJCalendar?
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
            
            print("dictionar")
            
            return dictionary
        }
    }
}

public extension Notification.Name {
    
    static var sjSubscribedToCalendar: Notification.Name {
        return .init("CalendarStore.subscribed")
    }
    
    static var sjPageViewed: Notification.Name {
        return .init("CalendarStore.page.viewed")
    }
    
    static var sjPlustButtonClicked: Notification.Name {
        return .init("CalendarStore.plus.button.clicked")
    }
    
    static var sjSubscribe: Notification.Name {
        return .init("CalendarStore.subscribe")
    }
    
    static var sjStartFreeTrial: Notification.Name {
        return .init("CalendarStore.start.free.trial")
    }
    
    static var sjAddCalendar: Notification.Name {
        return .init("CalendarStore.add.calendar")
    }
    
    
    
    
    /*
     
    static var sjPageViewed: Notification.Name {
        return .init("CalendarStore.")
    }
 */
    
}
