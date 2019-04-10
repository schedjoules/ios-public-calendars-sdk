//
//  SettingsObject.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 2018. 12. 17..
//  Copyright © 2018 SchedJoules. All rights reserved.
//

import Foundation
import SchedJoulesApiClient

struct SettingsObject: CodedOption {
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case name = "name"
        case icon = "icon"
        case path = "path"
    }
    
    
    let code: String
    let name: String
    var icon: URL?
    
    let path: String?
    
    
    init(object: CodedOption?, type: SettingsManager.SettingsType?) {        
        guard let validObject = object, let validType = type else {
            self.name = "Default"
            self.icon = nil
            self.path = nil
            
            if let type = type {
                switch type {
                case .country:
                    self.code = Locale.current.regionCode ?? ""
                case .language:
                    self.code = Locale.preferredLanguages[0].components(separatedBy: "-")[0]
                }
            } else {
                self.code = ""
            }
            
            return
        }
        
        self.name = validObject.name
        self.code = validObject.code
        self.icon = validObject.icon
        
        switch validType {
        case .language:
            path = UserDefaultsKeys.Settings.language
        case .country:
            path = UserDefaultsKeys.Settings.country
        }
    }
    
    init() {
        self.init(object: nil, type: nil)
    }
}


//Management
extension SettingsObject {
    
    func save() {
        SettingsManager.save(self)
    }
    
}


extension SettingsObject: Codable {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(name, forKey: .name)
        try container.encode(path, forKey: .path)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try values.decode(String.self, forKey: .code)
        self.name = try values.decode(String.self, forKey: .name)
        self.path = try values.decode(String.self, forKey: .path)
    }
}
