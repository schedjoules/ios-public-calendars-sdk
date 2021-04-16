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
    
    static var SJDidBecomeActive: Notification.Name {
        return .init("CalendarStore.did.become.active")
    }
    
    static var SJShareCalendar: Notification.Name {
        return .init("CalendarStore.share.calendar")
    }
    
    static var SJShowPurchaseScreen: Notification.Name {
        return .init("CalendarStore.show.purchase.screen")
    }
    
    static var SJClickPurchaseScreenButton: Notification.Name {
        return .init("CalendarStore.purchase.button.clicked")
    }
    
    static var SJPurchaseSubsctiption: Notification.Name {
        return .init("CalendarStore.purchase.subscription")
    }
    
    static var SJPurchaseSubscriptionFailed: Notification.Name {
        return .init("CalendarStore.purchase.failed")
    }
    
}
