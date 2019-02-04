//
//  Config.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 2019. 17. 29..
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation

class Config {
    
    static var uuid: String {
        guard let uuidExisting = UserDefaults.standard.uuid else {
            let uuidNew = UUID().uuidString
            UserDefaults.standard.uuid = uuidNew
            return uuidNew
        }
        return uuidExisting
    }
    
    static var bundleIdentifier: String {
        guard let bundleString = Bundle.main.infoDictionary?[kCFBundleIdentifierKey! as String] as? String else {
            return ""
        }
        return bundleString
    }
    
    static var bundleVersion: String {
        guard let bundleString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return bundleString
    }
    
    static var dateForAnalytics: Int {
        return Int(Date().timeIntervalSince1970)
    }
}
