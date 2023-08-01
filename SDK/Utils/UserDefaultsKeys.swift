//
//  UserDefaultsKeys.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 2018. 12. 15..
//  Copyright © 2018 SchedJoules. All rights reserved.
//

import Foundation

struct UserDefaultsKeys {
    
    struct Settings {
        static let country = "country_settings"
        static let language = "language_settings"
    }
    
    static let analytics = "analytics"
    
}

extension UserDefaults {
    
    var trackingHits: Array<[String : AnyObject]> {
        get { return array(forKey: #function) as? [[String : AnyObject]] ?? [] }
        set { set(newValue, forKey: #function) }
    }
    
    var uuid: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    
    public var subscriptionExpirationDate: Date? {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            let stringSaved = string(forKey: #function) ?? ""
            let expirationDate = dateFormatter.date(from: stringSaved)
            return expirationDate
        }
        set {
            guard let validNewValue = newValue else {
                return
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            let dateString = dateFormatter.string(from: validNewValue)
            set(dateString, forKey: #function)
        }
    }
    
    public var subscriptionId: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    
    var sjPurchaseModel: SJPurchaseModel {
        get { return SJPurchaseModel(rawValue: integer(forKey: #function)) ?? .freeTrial }
        set { set(newValue.rawValue, forKey: #function) }
    }
    
    public var originalTransaction: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    
    public var isNoSubscriptionConfirmed: Bool {
        get { return bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    
    public var temporalSubscriptionId: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}
