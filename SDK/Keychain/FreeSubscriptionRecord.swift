//
//  FreeSubscriptionRecord.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 4/24/20.
//  Copyright © 2020 SchedJoules. All rights reserved.
//

import UIKit

class FreeSubscriptionRecord {
    
    //Keychain setup
    let serviceName = "SchedJoules"
    let account = "CalendarSubscription-Test2"
    
    func canGetFreeCalendar() -> Bool {
        do {
            let calendar = try KeychainPasswordItem(service: serviceName,
                                                    account: account).readPassword()
            print("subscribed to calendar: ", calendar)
            return false
        } catch {
            print("keychain error: ", error)
            return true
        }
    }
    
}
