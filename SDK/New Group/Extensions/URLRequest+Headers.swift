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
    
    private func analyticsHeaders(apiKey: String) -> [String : String] {
        let headers: [String : String] =
            [
                Keys.authorization : String(format: "Token token=\"%@\"", apiKey),
                Keys.accept : "application/vnd.schedjoules; version=1",
                Keys.cache : "no-cache",
                Keys.contentType : "application/json",
                Keys.userAgent : userAgent,
                Keys.appId : "\(Config.bundleIdentifier)/\(Config.bundleVersion)",
                Keys.libraryVersion : "2.3.4-4-g8cd554c", //Don't know what is this value R = This is the SDK version
                Keys.uuid : Config.uuid,
                Keys.iosVersion : UIDevice.current.systemVersion,
                Keys.xAppId : "\(Config.bundleIdentifier)/\(Config.bundleVersion)",
                Keys.xLocale : SettingsObject(object: nil, type: .language).code,
                Keys.xUserId : Config.uuid
        ]
        return headers
    }
    
    private var userAgent: String {
        let productName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
        let productVersion = Config.bundleVersion
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        let systemLanguage = SettingsObject(object: nil, type: .language).code
        let systemCountry = SettingsObject(object: nil, type: .country).code
        
        let userAgentString = "\(productName)/\(productVersion) (\(deviceModel); U; CPU \(systemName) \(systemVersion) like Mac OS X; \(systemLanguage)-\(systemCountry))"
        
        return userAgentString
    }
    
    
    //Method to add headers to request
    
    mutating func setHeaders(for type: Kind, apiKey: String?) {
        
        guard let apiKey = apiKey else {
            sjPrint("there is no ApiKey set for SchedJoules")
            return
        }
        
        var headers: [String : String] = [:]
        
        switch type {
        case .analytics:
            headers = analyticsHeaders(apiKey: apiKey)
        }
        
        for (key, value) in headers {
            self.setValue(value, forHTTPHeaderField: key)
        }
    }
}

