//
//  NotificationName.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 10/1/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation

public extension Notification.Name {
    static var subscribedToCalendar: Notification.Name {
        return .init("CalendarStore.subscribed")
    }
}
