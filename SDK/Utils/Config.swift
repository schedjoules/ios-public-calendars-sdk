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
    
    static var appName: String {
        guard let infoKey = kCFBundleNameKey as String?,
            let info = Bundle.main.infoDictionary,
            let bundleString = info[infoKey] as? String else {
                return ""
        }
        return bundleString
    }
    
    static var subscriptionAccount: String {
        guard let infoKey = kCFBundleNameKey as String?,
            let info = Bundle.main.infoDictionary,
            var bundleString = info[infoKey] as? String else {
                return ""
        }
        
        if let clientAccount = UserDefaults.standard.string(forKey: "sjClientAccount") {
            bundleString += clientAccount
        }
        
        return bundleString
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
    
    static let libraryVersion: String = "0.9.19"
}
