//
//  SettingsManager.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 12/15/18.
//  Copyright © 2018 SchedJoules. All rights reserved.
//

import Foundation

class SettingsManager {
    
    enum SettingsType: String {
        case language
        case country
        
        var displayName: String {
            switch self {
            case .language:
                return "Language"
            case .country:
                return "Country"
            }
        }
        
        var path: String {
            switch self {
            case .language:
                return UserDefaultsKeys.Settings.language
            case .country:
                return UserDefaultsKeys.Settings.country
            }
        }
        
    } 
    
    static func get(type: SettingsType) -> SettingsObject {
        guard let existingData = UserDefaults.standard.object(forKey: type.path) as? Data,
            let existingObject = try? JSONDecoder().decode(SettingsObject.self, from: existingData) else {
                
                var defaultObject = SettingsObject()
                switch type {
                case .country:
                     defaultObject.code = Locale.current.regionCode ?? ""
                case .language:
                     defaultObject.code = Locale.preferredLanguages[0].components(separatedBy: "-")[0]
                }
                return defaultObject
        }
        return existingObject
    }
    
    static func save(_ object: SettingsObject) {
        guard let path = object.path else {
            fatalError("no path")
        }
        
        let encodedObject = try? JSONEncoder().encode(object)
        UserDefaults.standard.set(encodedObject, forKey: path)
    }
    
    static func delete(type: SettingsType) {
        UserDefaults.standard.removeObject(forKey: type.path)
    }
    
}
