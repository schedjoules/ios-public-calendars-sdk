//
//  URLRequest+Headers.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 1/16/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation
import UIKit

extension URLRequest {
    
    struct RequestHeader {
        let key: String
        let value: String
    }
    
    struct Keys {
        static let authorization = "Authorization"
        static let accept = "Accept"
        static let cache = "Cache-Control"
        static let contentType = "Content-Type"
        static let userAgent = "User-Agent"
        //iOS specific
        static let appId = "X-CalendarStore-AppId"
        static let libraryVersion = "X-CalendarStore-Library-Version"
        static let uuid = "X-CalendarStore-UUID"
        static let iosVersion = "X-CalendarStore-iOS"
        //cross-platform
        static let xAppId = "x-app-id"
        static let xLocale = "x-locale"
        static let xUserId = "x-user-Id"
    }
    
    enum Kind {
        case analytics
    }
    
    private var analyticsHeaders: [String : String] {
        get {
            let headers: [String : String] =
                [
                    Keys.authorization : authorization,
                    Keys.accept : "application/vnd.schedjoules; version=1",
                    Keys.cache : "no-cache",
                    Keys.contentType : "application/json",
                    Keys.userAgent : userAgent,
                    Keys.appId : "\(bundleIdentifier)/\(bundleVersion)",
                    Keys.libraryVersion : "2.3.4-4-g8cd554c", //Don't know what is this value
                    Keys.uuid : Config.uuid,
                    Keys.iosVersion : UIDevice.current.systemVersion,
                    Keys.xAppId : "\(bundleIdentifier)/\(bundleVersion)",
                    Keys.xLocale : SettingsObject(object: nil, type: .language).code,
                    Keys.xUserId : Config.uuid
            ]
            print(headers)
            return headers
        }
    }
    
    private var authorization: String {
        return "Token token=\"\(Config.apiKey)\""
    }
    
    private var bundleIdentifier: String {
        guard let bundleString = Bundle.main.infoDictionary?[kCFBundleIdentifierKey! as String] as? String else {
            return ""
        }
        return bundleString
    }
    
    private var bundleVersion: String {        
        guard let bundleString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return bundleString
    }
    
    private var userAgent: String {
        let productName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
        let productVersion = bundleVersion
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        let systemLanguage = SettingsObject(object: nil, type: .language).code
        let systemCountry = SettingsObject(object: nil, type: .country).code
        
        let userAgentString = "\(productName)/\(productVersion) (\(deviceModel); U; CPU \(systemName) \(systemVersion) like Mac OS X; \(systemLanguage)-\(systemCountry))"
        
        return userAgentString
    }

    
    //Method to add headers to request
    
    mutating func setHeaders(for type: Kind) {
        var headers: [String : String] = [:]
        
        switch type {
        case .analytics:
            headers = analyticsHeaders
        }
        
        for (key, value) in headers {
            self.setValue(value, forHTTPHeaderField: key)
        }
    }
}

