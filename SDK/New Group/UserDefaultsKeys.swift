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
    
    var trackingEvents: Array<[String : AnyObject]> {
        get { return array(forKey: #function) as? [[String : AnyObject]] ?? [] }
        set { set(newValue, forKey: #function) }
    }
    
    var uuid: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    
    
}

