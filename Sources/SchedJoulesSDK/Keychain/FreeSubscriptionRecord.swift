//
//  FreeSubscriptionRecord.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 4/24/20.
//  Copyright © 2020 SchedJoules. All rights reserved.
//

import UIKit

public class FreeSubscriptionRecord {
    
    //Keychain setup
    public let serviceName = "SchedJoules"
    public let account = "SJCalendarSubscription-\(Config.subscriptionAccount)"
    
    public init() {}
    
    func canGetFreeCalendar() -> Bool {
        switch UserDefaults.standard.sjPurchaseModel {
        case .freeTrial:
            return false
        case .freeCalendar:
            return freeCalendar() == nil
        case .openLicense:
            return false
        }
    }
    
    func freeCalendar() -> String? {
        do {
            let calendar = try KeychainPasswordItem(service: serviceName,
                                                    account: account).readPassword()
            print("subscribed to calendar: ", calendar)
            return calendar
        } catch {
            print("keychain error: ", error)
            return nil
        }
    }
    
}
