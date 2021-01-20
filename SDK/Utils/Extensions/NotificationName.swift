//
//  NotificationName.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 10/1/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation

public extension Notification.Name {
    
    static var SJSubscribedToCalendar: Notification.Name {
        return .init("CalendarStore.subscribed")
    }
    
    static var SJPageViewed: Notification.Name {
        return .init("CalendarStore.page.viewed")
    }
    
    static var SJPlustButtonClicked: Notification.Name {
        return .init("CalendarStore.plus.button.clicked")
    }
    
    static var SJSubscribeButtonClicked: Notification.Name {
        return .init("CalendarStore.subscribe.button.clicked")
    }
    
    static var SJStartFreeTrial: Notification.Name {
        return .init("CalendarStore.start.free.trial")
    }
    
    static var SJRegisterForAPNS: Notification.Name {
        return .init("CalendarStore.register.for.APNS")
    }
    
    static var SJUnregisterForAPNS: Notification.Name {
        return .init("CalendarStore.unregister.for.APNS")
    }
    
    static var SJAPNSUpdated: Notification.Name {
        return .init("CalendarStore.unregister.for.APNS")
    }
    
}
