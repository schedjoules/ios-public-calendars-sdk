//
//  Config.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 1/17/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation

class Config {
    
    static var apiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "SchedJoulesApiKey") as? String else {
            fatalError("No api key found. Add key SchedJoulesApiKey with your Api Key to your target's .plist")
        }
        return apiKey
    }
    
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
