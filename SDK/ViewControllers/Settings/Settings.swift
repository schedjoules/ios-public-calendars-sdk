//
//  File.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 12/15/18.
//  Copyright © 2018 SchedJoules. All rights reserved.
//

import Foundation

class Settings {
    
    static func readSettings() -> [String] {
        let languageSetting = UserDefaults.standard.value(forKey: DefaultsKeys.Settings.language) as? Dictionary<String, String>
        let locale = languageSetting != nil ? languageSetting!["countryCode"] : Locale.preferredLanguages[0].components(separatedBy: "-")[0]
        let countrySetting = UserDefaults.standard.value(forKey: DefaultsKeys.Settings.country) as? Dictionary<String, String>
        let location = countrySetting != nil ? countrySetting!["countryCode"] : Locale.current.regionCode
        return [locale!,location!]
    }
    
}
